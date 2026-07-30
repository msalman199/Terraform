#!/bin/bash

echo "=== Terraform Lab Cleanup ==="
echo "Date: $(date)"
echo "=============================="

# Backup current state
echo "1. Creating final backup..."
cp terraform.tfstate backups/terraform.tfstate.final-backup-$(date +%Y%m%d-%H%M%S)

# Show what will be destroyed
echo -e "\n2. Planning destruction..."
terraform plan -destroy

# Ask for confirmation
echo -e "\n3. Confirmation required:"
read -p "Do you want to destroy all resources? (yes/no): " CONFIRM

if [ "$CONFIRM" = "yes" ]; then
    echo "Destroying resources..."
    terraform destroy -auto-approve
    
    echo -e "\n4. Cleanup verification:"
    if [ $(terraform state list | wc -l) -eq 0 ]; then
        echo "✓ All resources destroyed successfully"
    else
        echo "✗ Some resources may still exist"
        terraform state list
    fi
    
    echo -e "\n5. File cleanup:"
    # Remove generated files (but keep configs and logs)
    rm -f welcome.txt README.md
    rm -f configs/app.conf configs/settings.json
    echo "✓ Generated files removed"
    
else
    echo "Cleanup cancelled by user"
fi

echo -e "\nCleanup completed at: $(date)"
