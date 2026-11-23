variable "project" {
  description = "Project name, used in resource names and tags."
  type        = string
  default     = "eks-platform"
}

variable "environment" {
  description = "Environment name (dev, prod, ...)."
  type        = string
}

variable "region" {
  description = "AWS region."
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block (/16)."
  type        = string
}

variable "az_count" {
  description = "Number of availability zones."
  type        = number
  default     = 3
}

variable "single_nat_gateway" {
  description = "One shared NAT gateway (cheap) instead of one per AZ (resilient)."
  type        = bool
}

variable "enable_flow_logs" {
  description = "Enable VPC flow logs."
  type        = bool
  default     = false
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster."
  type        = string
}

variable "endpoint_public_access" {
  description = "Expose the Kubernetes API publicly (restricted by CIDR)."
  type        = bool
  default     = true
}

variable "endpoint_public_access_cidrs" {
  description = "CIDRs allowed to reach the public Kubernetes API."
  type        = list(string)
}

variable "admin_principal_arns" {
  description = "Extra IAM principals granted cluster-admin."
  type        = list(string)
  default     = []
}

variable "node_groups" {
  description = "Managed node group definitions. See modules/eks/variables.tf for the full schema."
  type        = any
}

variable "ecr_repositories" {
  description = "ECR repositories to create."
  type        = list(string)
  default     = []
}

variable "extra_tags" {
  description = "Additional tags (e.g. CostCenter, Owner)."
  type        = map(string)
  default     = {}
}
