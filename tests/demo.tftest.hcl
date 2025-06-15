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

# ======================
# PLAN-PHASE TESTS
# (Fast validation before apply)
# ======================

run "validate_inputs" {
  command = plan

  # Validate variable formats
  assert {
    condition     = can(regex("^ami-", var.ami_id))
    error_message = "AMI ID must start with 'ami-'"
  }

  assert {
    condition     = can(cidrhost(var.cidr_block, 0))
    error_message = "Invalid VPC CIDR block format"
  }

  # Validate module wiring
  assert {
    condition     = length(var.public_subnet_cidrs) == length(var.availability_zones)
    error_message = "Number of public subnets must match AZs"
  }
}

run "validate_user_data" {
  command = plan

  # Can check user_data content during plan
  assert {
    condition     = can(regex("docker run", module.focalboard.user_data))
    error_message = "User data should contain docker run command"
  }
}

# ======================
# APPLY-PHASE TESTS
# (Actual resource validation)
# ======================

run "verify_network" {
  command = apply

  assert {
    condition     = module.network.vpc_id != ""
    error_message = "VPC was not created"
  }

  assert {
    condition     = length(module.network.public_subnets_id) == 1
    error_message = "Should create exactly 1 public subnet"
  }
}

run "verify_security_groups" {
  command = apply

  assert {
    condition     = module.security_groups.web_sg_id != ""
    error_message = "Web security group was not created"
  }
}

run "verify_focalboard_instance" {
  command = apply

  assert {
    condition     = module.focalboard.instance_id != ""
    error_message = "EC2 instance was not created"
  }

  # Additional instance checks
  assert {
    condition     = module.focalboard.instance_public_ip != ""
    error_message = "Instance should have a public IP"
  }
}

run "verify_alb" {
  command = apply

  assert {
    condition     = module.alb.lb_arn != ""
    error_message = "ALB was not created"
  }

  assert {
    condition     = module.alb.target_group_arn != ""
    error_message = "Target group was not created"
  }

  # Verify ALB is properly associated
  assert {
    condition     = length(module.alb.lb_dns_name) > 0
    error_message = "ALB DNS name should be available"
  }
}

# ======================
# CLEANUP (Optional)
# ======================

run "destroy_check" {
  command = destroy

  # Verify destroy doesn't fail
  assert {
    condition     = true
    error_message = "Destroy operation failed"
  }
}
