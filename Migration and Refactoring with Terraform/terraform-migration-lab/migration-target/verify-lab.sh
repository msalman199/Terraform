#!/bin/bash

echo "=== Lab 15 Verification Script ==="

# Check Terraform installation
echo "1. Checking Terraform installation..."
terraform version

# Check Docker installation
echo "2. Checking Docker installation..."
docker --version

# Verify imported resources
echo "3. Checking imported resources..."
cd ~/terraform-migration-lab/terraform-managed
terraform state list

# Verify migration target
echo "4. Checking migration target..."
cd ~/terraform-migration-lab/migration-target
terraform state list

# Check running containers
echo "5. Checking running containers..."
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"

# Test connectivity
echo "6. Testing service connectivity..."
curl -s http://localhost:8080 > /dev/null && echo "✓ East region web service accessible"
curl -s http://localhost:8081 > /dev/null && echo "✓ West region web service accessible"

echo "=== Verification Complete ==="
