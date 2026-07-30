#!/bin/bash
echo "=== TERRAFORM STATE ANALYSIS REPORT ==="
echo "Generated on: $(date)"
echo ""

echo "1. STATE FILE INFORMATION:"
echo "   File: $(pwd)/state-files/terraform.tfstate"
echo "   Size: $(stat -c%s state-files/terraform.tfstate) bytes"
echo "   Modified: $(stat -c%y state-files/terraform.tfstate)"
echo ""

echo "2. RESOURCES IN STATE:"
terraform state list | nl
echo ""

echo "3. STATE METADATA:"
terraform state pull | python3 -c "
import json, sys
state = json.load(sys.stdin)
print(f'   Terraform Version: {state.get(\"terraform_version\", \"N/A\")}')
print(f'   Serial Number: {state.get(\"serial\", \"N/A\")}')
print(f'   Lineage: {state.get(\"lineage\", \"N/A\")}')
print(f'   Resources Count: {len(state.get(\"resources\", []))}')
"
echo ""

echo "4. OUTPUT VALUES:"
terraform output
echo ""

echo "5. CREATED FILES:"
ls -la configs/
echo ""

echo "=== END OF REPORT ==="
