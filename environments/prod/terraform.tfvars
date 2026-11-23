# Prod: optimised for availability. 3 AZs, a NAT gateway per AZ, on-demand
# system nodes, Spot for stateless workloads, flow logs on.
environment = "prod"
region      = "ap-south-1"

vpc_cidr           = "10.20.0.0/16"
az_count           = 3
single_nat_gateway = false
enable_flow_logs   = true

cluster_version = "1.35"

# Restrict to your VPN / office egress IPs. Set endpoint_public_access = false
# if you reach the cluster only from inside the VPC (VPN, bastion, CI runners).
endpoint_public_access       = true
endpoint_public_access_cidrs = ["203.0.113.10/32"]

admin_principal_arns = []

node_groups = {
  system = {
    instance_types = ["m6i.large"]
    capacity_type  = "ON_DEMAND"
    min_size       = 3
    max_size       = 6
    desired_size   = 3
    labels = {
      workload = "system"
    }
  }

  spot = {
    instance_types = ["m6i.large", "m6a.large", "m5.large", "m5a.large"]
    capacity_type  = "SPOT"
    min_size       = 0
    max_size       = 10
    desired_size   = 2
    labels = {
      workload = "stateless"
    }
    taints = [{
      key    = "spot"
      value  = "true"
      effect = "NO_SCHEDULE"
    }]
  }
}

ecr_repositories = ["sample-app"]

extra_tags = {
  Owner = "platform-team"
}
