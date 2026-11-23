# Cluster add-ons installed with Helm. Each component that talks to AWS gets
# its own least-privilege IAM role via IRSA.

data "aws_region" "current" {}

# ---------------------------------------------------------------------------
# metrics-server: CPU/memory metrics for HPA and `kubectl top`
# ---------------------------------------------------------------------------
resource "helm_release" "metrics_server" {
  count = var.enable_metrics_server ? 1 : 0

  name       = "metrics-server"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  version    = var.chart_versions.metrics_server

  set {
    name  = "replicas"
    value = "2"
  }
}

# ---------------------------------------------------------------------------
# AWS Load Balancer Controller: Ingress -> ALB, Service type LoadBalancer -> NLB
# ---------------------------------------------------------------------------
module "lb_controller_irsa" {
  source = "../irsa"
  count  = var.enable_aws_load_balancer_controller ? 1 : 0

  role_name         = "${var.cluster_name}-aws-lb-controller"
  oidc_provider_arn = var.oidc_provider_arn
  oidc_provider_url = var.oidc_provider_url
  namespace         = "kube-system"
  service_account   = "aws-load-balancer-controller"
  # Official policy from the kubernetes-sigs/aws-load-balancer-controller repo.
  policy_json = file("${path.module}/policies/aws-load-balancer-controller.json")

  tags = var.tags
}

resource "helm_release" "aws_load_balancer_controller" {
  count = var.enable_aws_load_balancer_controller ? 1 : 0

  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = var.chart_versions.aws_load_balancer_controller

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "region"
    value = data.aws_region.current.name
  }

  set {
    name  = "vpcId"
    value = var.vpc_id
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.lb_controller_irsa[0].role_arn
  }

  set {
    name  = "replicaCount"
    value = "2"
  }
}

# ---------------------------------------------------------------------------
# Cluster Autoscaler: grows/shrinks node groups based on pending pods
# ---------------------------------------------------------------------------
data "aws_iam_policy_document" "cluster_autoscaler" {
  count = var.enable_cluster_autoscaler ? 1 : 0

  statement {
    sid = "ReadOnly"
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeScalingActivities",
      "autoscaling:DescribeTags",
      "ec2:DescribeImages",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeLaunchTemplateVersions",
      "ec2:GetInstanceTypesFromInstanceRequirements",
      "eks:DescribeNodegroup",
    ]
    resources = ["*"]
  }

  # Only allow scaling the ASGs that belong to this cluster.
  statement {
    sid = "ScaleOwnNodeGroups"
    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
    ]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/k8s.io/cluster-autoscaler/${var.cluster_name}"
      values   = ["owned"]
    }
  }
}

module "cluster_autoscaler_irsa" {
  source = "../irsa"
  count  = var.enable_cluster_autoscaler ? 1 : 0

  role_name         = "${var.cluster_name}-cluster-autoscaler"
  oidc_provider_arn = var.oidc_provider_arn
  oidc_provider_url = var.oidc_provider_url
  namespace         = "kube-system"
  service_account   = "cluster-autoscaler"
  policy_json       = data.aws_iam_policy_document.cluster_autoscaler[0].json

  tags = var.tags
}

resource "helm_release" "cluster_autoscaler" {
  count = var.enable_cluster_autoscaler ? 1 : 0

  name       = "cluster-autoscaler"
  namespace  = "kube-system"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  version    = var.chart_versions.cluster_autoscaler

  set {
    name  = "autoDiscovery.clusterName"
    value = var.cluster_name
  }

  set {
    name  = "awsRegion"
    value = data.aws_region.current.name
  }

  set {
    name  = "rbac.serviceAccount.name"
    value = "cluster-autoscaler"
  }

  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.cluster_autoscaler_irsa[0].role_arn
  }

  # Spread scale-ups across node groups and scale down idle nodes sooner.
  set {
    name  = "extraArgs.expander"
    value = "least-waste"
  }

  set {
    name  = "extraArgs.balance-similar-node-groups"
    value = "true"
  }

  set {
    name  = "extraArgs.skip-nodes-with-system-pods"
    value = "false"
  }

  set {
    name  = "extraArgs.scale-down-unneeded-time"
    value = var.scale_down_unneeded_time
  }
}
