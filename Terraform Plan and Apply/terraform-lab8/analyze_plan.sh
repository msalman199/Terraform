#!/bin/bash

echo "=== Terraform Plan Analysis ==="
echo "Date: $(date)"
echo "================================"

if [ -f "logs/initial-plan.log" ]; then
    echo "Resources to be added:"
    grep -c "will be created" logs/initial-plan.log
    
    echo -e "\nResources to be modified:"
    grep -c "will be updated" logs/initial-plan.log
    
    echo -e "\nResources to be destroyed:"
    grep -c "will be destroyed" logs/initial-plan.log
    
    echo -e "\nDetailed changes:"
    grep -E "(will be created|will be updated|will be destroyed)" logs/initial-plan.log
else
    echo "No plan log file found!"
