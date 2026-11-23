output "state_bucket" {
  description = "Name of the S3 bucket for Terraform state. Put this in environments/*/backend.tf."
  value       = aws_s3_bucket.state.id
}

output "lock_table" {
  description = "Name of the DynamoDB lock table. Put this in environments/*/backend.tf."
  value       = aws_dynamodb_table.lock.name
}

output "state_kms_key_arn" {
  description = "ARN of the KMS key that encrypts Terraform state. Add it as kms_key_id in backend.tf if you want the backend to enforce it."
  value       = aws_kms_key.state.arn
}
