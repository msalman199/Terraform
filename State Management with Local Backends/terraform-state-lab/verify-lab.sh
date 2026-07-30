#!/bin/bash
echo "=== LAB 4 VERIFICATION ==="

# Check 1: Terraform installation
if command -v terraform &> /dev/null; then
    echo "✓ Terraform is installed: $(terraform version --json | python3 -c 'import json,sys; print(json.load(sys.stdin)["terraform_version"])')"
else
    echo "✗ Terraform is not installed"
fi

# Check 2: State file exists
if [ -f "state-files/terraform.tfstate" ]; then
    echo "✓ State file exists"
else
    echo "✗ State file not found"
fi

# Check 3: Resources in state
RESOURCE_COUNT=$(terraform state list | wc -l)
if [ $RESOURCE_COUNT -gt 0 ]; then
    echo "✓ State contains $RESOURCE_COUNT resources"
else
    echo "✗ No resources found in state"
fi

# Check 4: Created files exist
if ls configs/*.txt &> /dev/null; then
    echo "✓ Configuration files created"
else
    echo "✗ Configuration files not found"
fi

# Check 5: Backup files exist
if ls backups/*.backup* &> /dev/null; then
    echo "✓ Backup files created"
else
    echo "✗ Backup files not found"
fi

echo "=== VERIFICATION COMPLETE ==="
