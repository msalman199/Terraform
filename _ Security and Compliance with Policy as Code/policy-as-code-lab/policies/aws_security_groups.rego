package terraform.aws.security_groups

import rego.v1

# Deny security groups that allow unrestricted inbound access
deny contains msg if {
    some resource in input.planned_values.root_module.resources
    resource.type == "aws_security_group"
    
    some rule in resource.values.ingress
    rule.cidr_blocks[_] == "0.0.0.0/0"
    rule.from_port == 0
    rule.to_port == 65535
    
    msg := sprintf("Security group '%s' allows unrestricted inbound access (0.0.0.0/0 on all ports)", [resource.name])
}

# Deny SSH access from anywhere
deny contains msg if {
    some resource in input.planned_values.root_module.resources
    resource.type == "aws_security_group"
    
    some rule in resource.values.ingress
    rule.cidr_blocks[_] == "0.0.0.0/0"
    rule.from_port <= 22
    rule.to_port >= 22
    
    msg := sprintf("Security group '%s' allows SSH access (port 22) from anywhere (0.0.0.0/0)", [resource.name])
}

# Deny RDP access from anywhere
deny contains msg if {
    some resource in input.planned_values.root_module.resources
    resource.type == "aws_security_group"
    
    some rule in resource.values.ingress
    rule.cidr_blocks[_] == "0.0.0.0/0"
    rule.from_port <= 3389
    rule.to_port >= 3389
    
    msg := sprintf("Security group '%s' allows RDP access (port 3389) from anywhere (0.0.0.0/0)", [resource.name])
}

# Require description for security group rules
deny contains msg if {
    some resource in input.planned_values.root_module.resources
    resource.type == "aws_security_group"
    
    some rule in resource.values.ingress
    not rule.description
    
    msg := sprintf("Security group '%s' has ingress rule without description", [resource.name])
}

# Warn about commonly attacked ports open to the internet
warn contains msg if {
    some resource in input.planned_values.root_module.resources
    resource.type == "aws_security_group"
    
    some rule in resource.values.ingress
    rule.cidr_blocks[_] == "0.0.0.0/0"
    
    risky_ports := [21, 23, 135, 139, 445, 1433, 3306, 5432]
    some port in risky_ports
    rule.from_port <= port
    rule.to_port >= port
    
    msg := sprintf("Security group '%s' exposes potentially risky port %d to the internet", [resource.name, port])
}
