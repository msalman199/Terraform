package terraform.aws.tagging

import rego.v1

# Required tags for all resources
required_tags := [
    "Environment",
    "Owner", 
    "Project",
    "CostCenter"
]

# Resources that must be tagged
taggable_resources := [
    "aws_instance",
    "aws_s3_bucket", 
    "aws_rds_instance",
    "aws_vpc",
    "aws_subnet",
    "aws_security_group"
]

# Deny resources missing required tags
deny contains msg if {
    some resource in input.planned_values.root_module.resources
    resource.type in taggable_resources
    
    some required_tag in required_tags
    not resource.values.tags[required_tag]
    
    msg := sprintf("Resource '%s' of type '%s' is missing required tag '%s'", [resource.name, resource.type, required_tag])
}

# Enforce tag value format for Environment
deny contains msg if {
    some resource in input.planned_values.root_module.resources
    resource.type in taggable_resources
    
    env_tag := resource.values.tags.Environment
    not env_tag in ["dev", "staging", "prod", "test"]
    
    msg := sprintf("Resource '%s' has invalid Environment tag value '%s'. Must be one of: dev, staging, prod, test", [resource.name, env_tag])
}

# Warn about resources with too many tags (potential overhead)
warn contains msg if {
    some resource in input.planned_values.root_module.resources
    resource.type in taggable_resources
    
    count(resource.values.tags) > 10
    
    msg := sprintf("Resource '%s' has %d tags, which may be excessive", [resource.name, count(resource.values.tags)])
}
