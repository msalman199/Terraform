#!/bin/bash

set -e

echo "Starting OPA Server for Policy Evaluation..."

# Start OPA server in the background
opa run --server --addr localhost:8181 ./policies &
OPA_PID=$!

echo "OPA Server started with PID: $OPA_PID"
echo "Server running at: http://localhost:8181"

# Wait for server to start
sleep 3

# Function to test policy via API
test_policy_api() {
    local policy_path=$1
    local input_file=$2
    
    echo "Testing policy: $policy_path"
    echo "Input file: $input_file"
    
    if [ -f "$input_file" ]; then
        curl -X POST http://localhost:8181/v1/data/$policy_path \
             -H 'Content-Type: application/json' \
             -d @$input_file | jq '.'
    else
        echo "Input file not found: $input_file"
    fi
}

# Create a sample input for testing
cat > test_input.json << 'EOFTEST'
{
    "input": {
        "planned_values": {
            "root_module": {
                "resources": [
                    {
                        "type": "aws_security_group",
                        "name": "test_sg",
                        "values": {
                            "ingress": [
                                {
                                    "from_port": 22,
                                    "to_port": 22,
                                    "protocol": "tcp",
                                    "cidr_blocks": ["0.0.0.0/0"]
                                }
                            ]
                        }
                    }
                ]
            }
        }
    }
}
EOFTEST

echo
echo "Testing Security Group Policy via API..."
test_policy_api "terraform/aws/security_groups" "test_input.json"

echo
echo "Press Ctrl+C to stop the OPA server"

# Keep script running
trap "kill $OPA_PID; exit" INT
wait $OPA_PID
