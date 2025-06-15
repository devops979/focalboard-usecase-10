output "vpc_id" {
  value = module.network.vpc_id
}

output "public_subnet_ids" {
  value = module.network.public_subnets_id
}

output "private_subnet_ids" {
  value = module.network.private_subnets_id
}

output "web_instance_ids" {
  value = module.focalboard.instance_id
}

output "web_instance_ips" {
  value = module.focalboard.public_ip
}


