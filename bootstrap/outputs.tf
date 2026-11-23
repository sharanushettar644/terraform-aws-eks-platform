output "state_bucket" {
  description = "Name of the S3 bucket for Terraform state. Put this in environments/*/backend.tf."
  value       = aws_s3_bucket.state.id
}

output "lock_table" {
  description = "Name of the DynamoDB lock table. Put this in environments/*/backend.tf."
  value       = aws_dynamodb_table.lock.name
}
