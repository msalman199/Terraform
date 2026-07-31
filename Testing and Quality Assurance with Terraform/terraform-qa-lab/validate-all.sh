#!/bin/bash

echo "=== Terraform Quality Assurance Report ==="
echo "Date: $(date)"
echo "Directory: $(pwd)"
echo ""

echo "1. Running Terraform Format Check..."
terraform fmt -check -diff
echo ""

echo "2. Running Terraform Validation..."
terraform validate
if [ $? -eq 0 ]; then
    echo "✓ Terraform validation passed"
else
    echo "✗ Terraform validation failed"
fi
echo ""

echo "3. Running tflint Analysis..."
tflint
echo ""

echo "4. Running tfsec Security Scan..."
tfsec --format=compact .
echo ""

echo "5. Generating Summary Reports..."
echo "- tflint report: tflint-report.json"
echo "- tfsec report: tfsec-report.json"
echo "- HTML security report: tfsec-report.html"

echo ""
echo "=== Quality Assurance Complete ==="
