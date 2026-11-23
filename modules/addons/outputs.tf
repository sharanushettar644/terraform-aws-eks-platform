output "aws_load_balancer_controller_role_arn" {
  description = "IAM role ARN used by the AWS Load Balancer Controller."
  value       = var.enable_aws_load_balancer_controller ? module.lb_controller_irsa[0].role_arn : null
}

output "cluster_autoscaler_role_arn" {
  description = "IAM role ARN used by Cluster Autoscaler."
  value       = var.enable_cluster_autoscaler ? module.cluster_autoscaler_irsa[0].role_arn : null
}
