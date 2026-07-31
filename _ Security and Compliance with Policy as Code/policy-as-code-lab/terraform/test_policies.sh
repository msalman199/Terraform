#!/bin/bash

set -e

echo "=== Policy as Code Security Testing ==="
echo

# Function to test Terraform configuration against policies
test_terraform_config() {
    local config_file=$1
    local config_name=$2
    
    echo "Testing $config_name configuration..."
    echo "----------------------------------------"
    
    cd terraform
    
    # Initialize Terraform
    terraform init -input=false > /dev/null 2>&1
    
    # Generate plan in JSON format
    terraform plan -out=tfplan -input=false > /dev/null 2>&1
    terraform show -json tfplan > plan.json
    
    cd ..
    
    # Test against all policies
    echo "Running policy checks..."
    if conftest test --policy ./policies terraform/plan.json; then
        echo "✅ All policy checks passed for $config_name"
    else
        echo "❌ Policy violations found in $config_name"
    fi
    
    echo
    echo "Detailed policy evaluation:"
    conftest test --policy ./policies terraform/plan.json --output table || true
    
    echo
    echo "----------------------------------------"
    echo
}

# Test the non-compliant configuration
if [ -f "terraform/main.tf" ]; then
    test_terraform_config "main.tf" "Non-Compliant"
fi

# Test the compliant configuration
if [ -f "terraform/main_compliant.tf" ]; then
    # Temporarily rename files to test compliant version
    cd terraform
    if [ -f "main.tf" ]; then
        mv main.tf main_bad.tf
    fi
    mv main_compliant.tf main.tf
    cd ..
    
    test_terraform_config "main.tf" "Compliant"
    
    # Restore original files
    cd terraform
    mv main.tf main_compliant.tf
    if [ -f "main_bad.tf" ]; then
        mv main_bad.tf main.tf
    fi
    cd ..
fi

echo "=== Testing Complete ==="
