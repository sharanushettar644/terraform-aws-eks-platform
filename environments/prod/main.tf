locals {
  name = "${var.project}-${var.environment}"

  tags = merge(var.extra_tags, {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
    Repository  = "terraform-aws-eks-platform"
  })
}

module "vpc" {
  source = "../../modules/vpc"

  name               = local.name
  cluster_name       = local.name
  vpc_cidr           = var.vpc_cidr
  az_count           = var.az_count
  single_nat_gateway = var.single_nat_gateway
  enable_flow_logs   = var.enable_flow_logs

  tags = local.tags
}

module "eks" {
  source = "../../modules/eks"

  cluster_name                 = local.name
  cluster_version              = var.cluster_version
  private_subnet_ids           = module.vpc.private_subnet_ids
  endpoint_public_access       = var.endpoint_public_access
  endpoint_public_access_cidrs = var.endpoint_public_access_cidrs
  admin_principal_arns         = var.admin_principal_arns
  node_groups                  = var.node_groups

  tags = local.tags
}

module "ecr" {
  source = "../../modules/ecr"

  name_prefix  = var.environment
  repositories = var.ecr_repositories
  force_delete = var.environment != "prod"

  tags = local.tags
}

module "addons" {
  source = "../../modules/addons"

  cluster_name      = module.eks.cluster_name
  vpc_id            = module.vpc.vpc_id
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url

  tags = local.tags

  # Add-on pods need nodes, CoreDNS and the VPC CNI to be ready.
  depends_on = [module.eks]
}
