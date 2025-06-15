package terraform.validation

import rego.v1

# Subnet validation
deny contains msg if {
  resource := input.planned_values.root_module.resources[_]
  resource.type == "aws_subnet"
  contains(resource.values.cidr_block, "0.0.0.0/0")
  not resource.values.tags["Environment"]
  msg := sprintf("Subnet %s is public and lacks 'Environment' tag", [resource.name])
}

# EC2 instance validation
deny contains msg if {
  resource := input.planned_values.root_module.resources[_]
  resource.type == "aws_instance"
  not resource.values.user_data
  msg := sprintf("EC2 instance %s is missing user_data script", [resource.name])
}

# ALB validation
deny contains msg if {
  resource := input.planned_values.root_module.resources[_]
  resource.type == "aws_lb"
  not startswith(resource.values.name, "web-")
  msg := sprintf("ALB %s does not follow 'web-' naming convention", [resource.name])
}

# Target group validation
deny contains msg if {
  resource := input.planned_values.root_module.resources[_]
  resource.type == "aws_lb_target_group"
  not resource.values.health_check
  msg := sprintf("Target group %s is missing health check config", [resource.name])
}

# Security group rule validation
deny contains msg if {
  resource := input.planned_values.root_module.resources[_]
  resource.type == "aws_security_group_rule"
  resource.values.type == "ingress"
  resource.values.cidr_blocks[_] == "0.0.0.0/0"
  not resource.values.from_port == 80
  not resource.values.from_port == 443
  msg := sprintf("Security group rule in %s allows 0.0.0.0/0 on non-HTTP(S) port", [resource.name])
}
