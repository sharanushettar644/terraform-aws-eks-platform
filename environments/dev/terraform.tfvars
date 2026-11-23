# Dev: optimised for cost. One NAT gateway, 2 AZs, Spot nodes.
environment = "dev"
region      = "ap-south-1"

vpc_cidr           = "10.10.0.0/16"
az_count           = 2
single_nat_gateway = true
enable_flow_logs   = false

cluster_version = "1.35"

# Replace with your own public IP (curl ifconfig.me) followed by /32.
endpoint_public_access       = true
endpoint_public_access_cidrs = ["203.0.113.10/32"]

# e.g. ["arn:aws:iam::123456789012:role/github-actions-terraform"]
admin_principal_arns = []

node_groups = {
  general = {
    # Several similar sizes = better Spot availability.
    instance_types = ["t3.large", "t3a.large", "m5.large"]
    capacity_type  = "SPOT"
    min_size       = 1
    max_size       = 4
    desired_size   = 2
  }
}

ecr_repositories = ["sample-app"]

extra_tags = {
  Owner = "platform-team"
}
