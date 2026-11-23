# Remote state created by ../../bootstrap. Replace ACCOUNT_ID with your AWS
# account ID (see the bootstrap output "state_bucket").
terraform {
  backend "s3" {
    bucket         = "eks-platform-tfstate-ACCOUNT_ID"
    key            = "environments/prod/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "eks-platform-tfstate-lock"
    encrypt        = true
  }
}
