#!/bin/bash

set -e

echo "=== CI/CD Pipeline Policy Integration Demo ==="
echo

# Simulate CI/CD environment variables
export ENVIRONMENT=${ENVIRONMENT:-"dev"}
export BRANCH_NAME=${BRANCH_NAME:-"feature/security-updates"}

echo "Environment: $ENVIRONMENT"
echo "Branch: $BRANCH_NAME"
echo

# Function to run security checks
run_security_checks() {
    local exit_code=0
    
    echo "Step 1: Terraform Validation"
    cd terraform
    terraform fmt -check || { echo "❌ Terraform formatting issues found"; exit_code=1; }
    terraform validate || { echo "❌ Terraform validation failed"; exit_code=1; }
    echo "✅ Terraform validation passed"
    
    echo
    echo "Step 2: Generate Terraform Plan"
    terraform plan -out=tfplan -input=false
    terraform show -json tfplan > plan.json
    echo "✅ Terraform plan generated"
    
    cd ..
    
    echo
    echo "Step 3: Security Policy Checks"
    if conftest test --policy ./policies terraform/plan.json --output table; then
        echo "✅ All security policies passed"
    else
        echo "❌ Security policy violations found"
        exit_code=1
    fi
    
    echo
    echo "Step 4: Generate Security Report"
    conftest test --policy ./policies terraform/plan.json --output json > security_report.json
    echo "✅ Security report generated: security_report.json"
    
    return $exit_code
}

# Run the security checks
if run_security_checks; then
    echo
    echo "🎉 All security checks passed! Ready for deployment."
    exit 0
else
    echo
    echo "🚫 Security checks failed! Deployment blocked."
    echo "Please fix the policy violations before proceeding."
    exit 1
fi
