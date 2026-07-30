#!/bin/bash

echo "=== Change Detection Analysis ==="
echo "Date: $(date)"
echo "================================="

# Count different types of changes
ADDITIONS=$(grep -c "will be created" logs/modification-plan.log 2>/dev/null || echo "0")
MODIFICATIONS=$(grep -c "will be updated in-place" logs/modification-plan.log 2>/dev/null || echo "0")
DESTRUCTIONS=$(grep -c "will be destroyed" logs/modification-plan.log 2>/dev/null || echo "0")

echo "Resources to be added: $ADDITIONS"
echo "Resources to be modified: $MODIFICATIONS"
echo "Resources to be destroyed: $DESTRUCTIONS"

echo -e "\nDetailed change summary:"
if [ -f "logs/modification-plan.log" ]; then
    grep -E "(will be created|will be updated|will be destroyed)" logs/modification-plan.log
else
    echo "No modification plan found!"
fi

echo -e "\nChange impact assessment:"
TOTAL_CHANGES=$((ADDITIONS + MODIFICATIONS + DESTRUCTIONS))
echo "Total changes: $TOTAL_CHANGES"

if [ $TOTAL_CHANGES -eq 0 ]; then
    echo "Status: No changes detected - infrastructure is up to date"
elif [ $TOTAL_CHANGES -le 3 ]; then
    echo "Status: Low impact changes"
elif [ $TOTAL_CHANGES -le 6 ]; then
    echo "Status: Medium impact changes"
else
    echo "Status: High impact changes - review carefully"
fi
