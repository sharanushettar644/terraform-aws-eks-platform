output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC."
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets (load balancers, NAT)."
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets (nodes, pods)."
  value       = aws_subnet.private[*].id
}

output "azs" {
  description = "Availability zones in use."
  value       = local.azs
}

output "nat_public_ips" {
  description = "Public IPs of the NAT gateways (useful for allow-listing egress)."
  value       = aws_eip.nat[*].public_ip
}
