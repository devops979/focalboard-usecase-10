variables {
  region               = "us-east-1"
  cidr_block          = "10.0.0.0/16"
  environment         = "test"
  public_subnet_cidrs = ["10.0.1.0/24"]
  private_subnet_cidrs = ["10.0.2.0/24"]
  availability_zones  = ["us-east-1a"]
  key_name            = "test-key"
  ami_id              = "ami-12345678"
  instance_type       = "t2.micro"
}

run "verify_network_module" {
  command = plan

  assert {
    condition     = module.network.vpc_id != ""
    error_message = "VPC ID should not be empty"
  }

  assert {
    condition     = length(module.network.public_subnets_id) == 1
    error_message = "Should create 1 public subnet"
  }
}

run "verify_security_groups" {
  command = plan

  assert {
    condition     = module.security_groups.web_sg_id != ""
    error_message = "Web security group ID should not be empty"
  }
}

run "verify_focalboard_instance" {
  command = plan

  assert {
    condition     = module.focalboard.instance_id != ""
    error_message = "Instance ID should not be empty"
  }

  assert {
    condition     = can(regex("docker run", module.focalboard.user_data))
    error_message = "User data should contain docker run command"
  }
}

run "verify_alb_configuration" {
  command = plan

  assert {
    condition     = module.alb.lb_arn != ""
    error_message = "ALB ARN should not be empty"
  }

  assert {
    condition     = module.alb.target_group_arn != ""
    error_message = "Target group ARN should not be empty"
  }
}
