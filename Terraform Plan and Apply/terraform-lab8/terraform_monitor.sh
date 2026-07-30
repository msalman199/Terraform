#!/bin/bash

LOG_FILE="logs/terraform-monitor-$(date +%Y%m%d-%H%M%S).log"

echo "=== Terraform Infrastructure Monitor ===" | tee -a $LOG_FILE
echo "Started at: $(date)" | tee -a $LOG_FILE
echo "=========================================" | tee -a $LOG_FILE

# Check Terraform version
echo -e "\n1. Terraform Version:" | tee -a $LOG_FILE
terraform version | tee -a $LOG_FILE

# Validate configuration
echo -e "\n2. Configuration Validation:" | tee -a $LOG_FILE
if terraform validate; then
    echo "✓ Configuration is valid" | tee -a $LOG_FILE
else
    echo "✗ Configuration has errors" | tee -a $LOG_FILE
fi

# Check formatting
echo -e "\n3. Configuration Formatting:" | tee -a $LOG_FILE
if terraform fmt -check; then
    echo "✓ Configuration is properly formatted" | tee -a $LOG_FILE
else
    echo "! Configuration formatting issues detected" | tee -a $LOG_FILE
    terraform fmt
    echo "✓ Configuration formatted" | tee -a $LOG_FILE
fi

# Plan check
echo -e "\n4. Infrastructure Plan:" | tee -a $LOG_FILE
terraform plan -detailed-exitcode > /dev/null 2>&1
PLAN_EXIT_CODE=$?

case $PLAN_EXIT_CODE in
    0)
        echo "✓ No changes needed - infrastructure is up to date" | tee -a $LOG_FILE
        ;;
    1)
        echo "✗ Plan failed - check configuration" | tee -a $LOG_FILE
        ;;
    2)
        echo "! Changes detected - review plan before applying" | tee -a $LOG_FILE
        terraform plan | tee -a $LOG_FILE
        ;;
esac

# State information
echo -e "\n5. Current State:" | tee -a $LOG_FILE
RESOURCE_COUNT=$(terraform state list 2>/dev/null | wc -l)
echo "Resources in state: $RESOURCE_COUNT" | tee -a $LOG_FILE

if [ $RESOURCE_COUNT -gt 0 ]; then
    echo "Resources:" | tee -a $LOG_FILE
    terraform state list | sed 's/^/  - /' | tee -a $LOG_FILE
fi

# File verification
echo -e "\n6. Managed Files Verification:" | tee -a $LOG_FILE
MANAGED_FILES=("welcome.txt" "configs/app.conf" "configs/settings.json" "README.md")

for file in "${MANAGED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✓ $file exists" | tee -a $LOG_FILE
    else
        echo "✗ $file missing" | tee -a $LOG_FILE
    fi
done

echo -e "\n=========================================" | tee -a $LOG_FILE
echo "Monitor completed at: $(date)" | tee -a $LOG_FILE
echo "Log saved to: $LOG_FILE" | tee -a $LOG_FILE
