variable "name" {
  description = "Name prefix for all VPC resources."
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name, used for the subnet discovery tags."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC. Must be a /16 for the default subnet layout."
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0)) && endswith(var.vpc_cidr, "/16")
    error_message = "vpc_cidr must be a valid /16 CIDR block, e.g. 10.0.0.0/16."
  }
}

variable "az_count" {
  description = "Number of availability zones to spread subnets across (2 or 3)."
  type        = number
  default     = 3

  validation {
    condition     = var.az_count >= 2 && var.az_count <= 3
    error_message = "az_count must be 2 or 3."
  }
}

variable "single_nat_gateway" {
  description = "Use one shared NAT gateway (cheaper, not AZ-resilient) instead of one per AZ."
  type        = bool
  default     = false
}

variable "enable_flow_logs" {
  description = "Send VPC flow logs to CloudWatch Logs."
  type        = bool
  default     = false
}

variable "flow_logs_retention_days" {
  description = "Retention period for VPC flow logs."
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
  default     = {}
}
