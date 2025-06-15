provider "aws" {
  region = var.region
}


module "network" {
  source             = "./modules/network"
  vpc_cidr           = var.cidr_block
  vpc_name           = "demo-webapp-vpc"
  environment        = var.environment
  public_cidr_block  = var.public_subnet_cidrs
  private_cidr_block = var.private_subnet_cidrs
  azs                = var.availability_zones
  owner              = "demo-webapp-focalboard"
}



module "security_groups" {
  source = "./modules/security_groups"
  vpc_id = module.network.vpc_id
  tags   = var.tags
}



module "focalboard" {
  source         = "./modules/focalboard"
  key_name       = var.key_name
  ami_name       = var.ami_id
  sg_id          = module.security_groups.web_sg_id
  vpc_name       = module.network.vpc_name
  public_subnets = module.network.public_subnets_id[0]
  instance_type  = var.instance_type
  project_name   = "demo-instance-focalboard"

  user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt-get install -y docker.io
                sudo systemctl start docker
                sudo systemctl enable docker
                sudo  docker run -d -p 8000:8000 mattermost/focalboard
                EOF
}



module "alb" {
  source                = "./modules/alb"
  name                  = "web-lb"
  security_group_id     = module.security_groups.web_sg_id
  subnet_ids            = module.network.public_subnets_id
  target_group_name     = "web-target-group"
  target_group_port     = 8000
  target_group_protocol = "HTTP"
  vpc_id                = module.network.vpc_id
  health_check_path     = "/"
  health_check_protocol = "HTTP"
  health_check_interval = 30
  health_check_timeout  = 5
  healthy_threshold     = 2
  unhealthy_threshold   = 2
  listener_port         = 80
  listener_protocol     = "HTTP"
  target_ids            = module.focalboard.instance_id
  tags                  = var.tags
}


