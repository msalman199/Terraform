package terraform.aws.iam

import rego.v1

# Deny IAM policies that grant wildcard permissions on all resources
deny contains msg if {
    some resource in input.planned_values.root_module.resources
    resource.type == "aws_iam_policy"
    
    policy_doc := json.unmarshal(resource.values.policy)
    some statement in policy_doc.Statement
    
    # Check for wildcard actions
    statement.Action == "*"
    statement.Resource == "*"
    
    msg := sprintf("IAM policy '%s' grants wildcard permissions (*:*) which violates least privilege principle", [resource.name])
}

# Deny IAM roles that can be assumed by any AWS account
deny contains msg if {
    some resource in input.planned_values.root_module.resources
    resource.type == "aws_iam_role"
    
    assume_role_doc := json.unmarshal(resource.values.assume_role_policy)
    some statement in assume_role_doc.Statement
    
    statement.Principal.AWS == "*"
    
    msg := sprintf("IAM role '%s' can be assumed by any AWS account (*), which is a security risk", [resource.name])
}

# Require MFA for sensitive IAM policies
deny contains msg if {
    some resource in input.planned_values.root_module.resources
    resource.type == "aws_iam_policy"
    
    policy_doc := json.unmarshal(resource.values.policy)
    some statement in policy_doc.Statement
    
    # Check for sensitive actions without MFA condition
    sensitive_actions := [
        "iam:CreateUser",
        "iam:DeleteUser", 
        "iam:CreateRole",
        "iam:DeleteRole",
        "s3:DeleteBucket"
    ]
    
    some action in sensitive_actions
    action in statement.Action
    
    not statement.Condition["Bool"]["aws:MultiFactorAuthPresent"]
    
    msg := sprintf("IAM policy '%s' allows sensitive action '%s' without requiring MFA", [resource.name, action])
}

# Warn about overly broad S3 permissions
warn contains msg if {
    some resource in input.planned_values.root_module.resources
    resource.type == "aws_iam_policy"
    
    policy_doc := json.unmarshal(resource.values.policy)
    some statement in policy_doc.Statement
    
    "s3:*" in statement.Action
    statement.Resource == "arn:aws:s3:::*"
    
    msg := sprintf("IAM policy '%s' grants broad S3 permissions (s3:* on all buckets)", [resource.name])
}
