#!/bin/bash

echo "=== Lab Verification ==="
echo

# Check installed tools
echo "Checking installed tools..."
terraform version || echo "❌ Terraform not installed"
opa version || echo "❌ OPA not installed"  
conftest --version || echo "❌ Conftest not installed"

echo
echo "Checking policy files..."
ls -la policies/

echo
echo "Checking Terraform configurations..."
ls -la terraform/

echo
echo "Running quick policy test..."
cd terraform
terraform init -input=false > /dev/null 2>&1
terraform plan -out=tfplan -input=false > /dev/null 2>&1
terraform show -json tfplan > plan.json
cd ..

conftest test --policy ./policies terraform/plan.json --output table

echo
echo "=== Verification Complete ==="
