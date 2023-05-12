output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}
output "efs_dns_name" {
  value = module.efs.dns_name
}
output "efs_arn" {
  value = module.efs.arn
}

output "instance_id-1" {
  value = module.ec2-instance2.id
}
output "instance_id-2" {
  value = module.ec2-instance1.id
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

