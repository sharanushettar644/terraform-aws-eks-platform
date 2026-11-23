variable "role_name" {
  description = "Name of the IAM role."
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the cluster's IAM OIDC provider."
  type        = string
}

variable "oidc_provider_url" {
  description = "Issuer URL of the cluster's OIDC provider."
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace of the service account."
  type        = string
}

variable "service_account" {
  description = "Name of the Kubernetes service account allowed to assume the role."
  type        = string
}

variable "policy_json" {
  description = "Optional custom IAM policy document (JSON) to attach."
  type        = string
  default     = null
}

variable "managed_policy_arns" {
  description = "Optional AWS-managed policy ARNs to attach."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags applied to IAM resources."
  type        = map(string)
  default     = {}
}
