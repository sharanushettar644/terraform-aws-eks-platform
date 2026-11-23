variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID (required by the AWS Load Balancer Controller)."
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the cluster's IAM OIDC provider."
  type        = string
}

variable "oidc_provider_url" {
  description = "Issuer URL of the cluster's IAM OIDC provider."
  type        = string
}

variable "enable_metrics_server" {
  description = "Install metrics-server."
  type        = bool
  default     = true
}

variable "enable_aws_load_balancer_controller" {
  description = "Install the AWS Load Balancer Controller."
  type        = bool
  default     = true
}

variable "enable_cluster_autoscaler" {
  description = "Install Cluster Autoscaler."
  type        = bool
  default     = true
}

variable "scale_down_unneeded_time" {
  description = "How long a node must be unneeded before Cluster Autoscaler removes it."
  type        = string
  default     = "10m"
}

variable "chart_versions" {
  description = "Pinned Helm chart versions. Bump deliberately, and test in dev first."
  type = object({
    metrics_server               = string
    aws_load_balancer_controller = string
    cluster_autoscaler           = string
  })
  default = {
    metrics_server               = "3.12.2"
    aws_load_balancer_controller = "1.11.0"
    cluster_autoscaler           = "9.46.0"
  }
}

variable "tags" {
  description = "Tags applied to IAM resources."
  type        = map(string)
  default     = {}
}
