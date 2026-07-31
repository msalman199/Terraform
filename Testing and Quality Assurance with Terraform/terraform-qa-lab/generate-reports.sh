#!/bin/bash

REPORT_DIR="qa-reports"
mkdir -p $REPORT_DIR

echo "📊 Generating comprehensive QA reports..."

# Generate tflint report
echo "Generating tflint report..."
tflint --format=json > $REPORT_DIR/tflint-report.json
tflint --format=compact > $REPORT_DIR/tflint-report.txt

# Generate tfsec reports
echo "Generating tfsec reports..."
tfsec --format=json . > $REPORT_DIR/tfsec-report.json
tfsec --format=html . > $REPORT_DIR/tfsec-report.html
tfsec --format=csv . > $REPORT_DIR/tfsec-report.csv

# Generate terraform validation report
echo "Generating terraform validation report..."
terraform validate -json > $REPORT_DIR/terraform-validate.json

# Create summary report
cat > $REPORT_DIR/summary.md << 'SUMMARY'
# Terraform Quality Assurance Summary

## Report Generation Date
$(date)

## Files Analyzed
$(find . -name "*.tf" -type f | wc -l) Terraform files

## Reports Generated
- tflint-report.json: Detailed linting analysis
- tflint-report.txt: Human-readable linting report
- tfsec-report.json: Security analysis (JSON)
- tfsec-report.html: Security analysis (HTML)
- tfsec-report.csv: Security analysis (CSV)
- terraform-validate.json: Syntax validation results

## Quick Stats
- Total .tf files: $(find . -name "*.tf" -type f | wc -l)
- Total lines of code: $(find . -name "*.tf" -exec wc -l {} + | tail -1 | awk '{print $1}')

SUMMARY

echo "✅ Reports generated in $REPORT_DIR/"
ls -la $REPORT_DIR/
