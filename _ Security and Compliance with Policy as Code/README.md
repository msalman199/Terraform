<div align="center">

# 🛡️ Security and Compliance with Policy as Code

### Enforcing Least Privilege and Security Guardrails with Open Policy Agent

![OPA](https://img.shields.io/badge/Open%20Policy%20Agent-7D9D9C?style=for-the-badge&logo=openpolicyagent&logoColor=white)
![Rego](https://img.shields.io/badge/Rego-2C3E50?style=for-the-badge&logo=data:image/svg+xml;base64,&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-844FBA?style=for-the-badge&logo=terraform&logoColor=white)
![Conftest](https://img.shields.io/badge/Conftest-1F1F1F?style=for-the-badge&logo=openpolicyagent&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Bash](https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-2088FF?style=for-the-badge&logo=github-actions&logoColor=white)
![DevSecOps](https://img.shields.io/badge/DevSecOps-000000?style=for-the-badge&logo=shieldsdotio&logoColor=white)

</div>

---

## 📋 Table of Contents

- [🎯 Lab Objectives](#-lab-objectives)
- [📌 Prerequisites](#-prerequisites)
- [🖥️ Lab Environment](#️-lab-environment)
- [⚙️ Task 1: Set up OPA (Open Policy Agent) for Policy Enforcement](#️-task-1-set-up-opa-open-policy-agent-for-policy-enforcement)
- [🔐 Task 2: Write Policies to Enforce Least Privilege Access](#-task-2-write-policies-to-enforce-least-privilege-access)
- [🔗 Task 3: Integrate OPA with Terraform for Security Checks](#-task-3-integrate-opa-with-terraform-for-security-checks)
- [✅ Verification and Testing](#-verification-and-testing)
- [🛠️ Troubleshooting Common Issues](#️-troubleshooting-common-issues)
- [🗺️ MITRE ATT&CK Mapping](#️-mitre-attck-mapping)
- [🧠 Key Concepts](#-key-concepts)
- [🏁 Conclusion](#-conclusion)

---

## 🎯 Lab Objectives

By the end of this lab, students will be able to:

| # | Objective |
|---|-----------|
| 1 | ⚙️ Install and configure **Open Policy Agent (OPA)** on a Linux system |
| 2 | 📝 Write **Rego** policies to enforce security best practices and least privilege access |
| 3 | 🔗 Integrate OPA with **Terraform** to perform automated security checks |
| 4 | 🚦 Implement policy-as-code workflows for infrastructure compliance |
| 5 | ✅ Validate Terraform configurations against security policies before deployment |
| 6 | ⬅️ Understand the principles of **shift-left security** in infrastructure automation |

---

## 📌 Prerequisites

| Requirement | Details |
|-------------|---------|
| 💻 Linux CLI | Basic understanding of Linux command line operations |
| 🌍 Terraform | Familiarity with Terraform fundamentals and HCL syntax |
| ☁️ Cloud Concepts | Knowledge of cloud infrastructure concepts (IAM, security groups, etc.) |
| 📄 Data Formats | Understanding of JSON and YAML file formats |
| 🔒 Security Basics | Basic knowledge of security principles and access control concepts |

---

## 🖥️ Lab Environment

> 💡 Al Nafi provides Linux-based cloud machines for this lab. Simply click **Start Lab** to access your dedicated environment. The provided Linux machine is **bare metal with no pre-installed tools** — you will install all required software during the lab exercises.
>
> 🖥️ All tasks in this lab are performed on a **single Linux machine**. No additional virtual machines or remote hosts are required.

---

## ⚙️ Task 1: Set up OPA (Open Policy Agent) for Policy Enforcement

### 📦 Subtask 1.1: Install Required Dependencies

**1️⃣ Update your system and install essential tools:**
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget unzip git jq
```

### 🌍 Subtask 1.2: Install Terraform

**1️⃣ Download the latest version of Terraform:**
```bash
# 📥 Download Terraform
wget https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_linux_amd64.zip

# 📦 Unzip and install
unzip terraform_1.6.6_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# 🔍 Verify installation
terraform version
```

### ⚖️ Subtask 1.3: Install Open Policy Agent (OPA)

**1️⃣ Download and install OPA:**
```bash
# 📥 Download OPA binary
curl -L -o opa https://openpolicyagent.org/downloads/v0.58.0/opa_linux_amd64_static

# ✅ Make it executable and move to system path
chmod +x opa
sudo mv opa /usr/local/bin/

# 🔍 Verify OPA installation
opa version
```

### 🧪 Subtask 1.4: Install Conftest for Policy Testing

> ℹ️ Conftest is a utility that helps test structured configuration data against OPA policies.

```bash
# 📥 Download Conftest
wget https://github.com/open-policy-agent/conftest/releases/download/v0.46.0/conftest_0.46.0_Linux_x86_64.tar.gz

# 📦 Extract and install
tar -xzf conftest_0.46.0_Linux_x86_64.tar.gz
sudo mv conftest /usr/local/bin/

# 🔍 Verify installation
conftest --version
```

### 📁 Subtask 1.5: Create Lab Directory Structure

**1️⃣ Set up the working directory for the lab:**
```bash
# 📂 Create main lab directory
mkdir -p ~/policy-as-code-lab
cd ~/policy-as-code-lab

# 🗂️ Create subdirectories for organization
mkdir -p {policies,terraform,tests,examples}

# 👀 Create initial directory structure
tree . || ls -la
```

> 🎓 **TODO:** Before moving on, sketch (on paper or in a comment) which AWS resource types in your own environment would need `deny` vs `warn` rules — you'll build exactly that distinction in Task 2.

---

## 🔐 Task 2: Write Policies to Enforce Least Privilege Access

### 🔑 Subtask 2.1: Create AWS IAM Policy for Least Privilege

**1️⃣ Create the IAM policy file:**
```rego
cat > policies/aws_iam_least_privilege.rego << 'EOF'
package terraform.aws.iam

import rego.v1

# 🚫 Deny IAM policies that grant wildcard permissions on all resources
deny contains msg if {
    some resource in input.planned_values.root_module.resources
    resource.type == "aws_iam_policy"

    policy_doc := json.unmarshal(resource.values.policy)
    some statement in policy_doc.Statement

    # Check for wildcard actions
    statement.Action == "*"
    statement.Resource == "*"

    msg := sprintf("IAM policy '%s' grants wildcard permissions (*:*) which violates least privilege principle", [resource.name])
}

# 🚫 Deny IAM roles that can be assumed by any AWS account
deny contains msg if {
    some resource in input.planned_values.root_module.resources
    resource.type == "aws_iam_role"

    assume_role_doc := json.unmarshal(resource.values.assume_role_policy)
    some statement in assume_role_doc.Statement

    statement.Principal.AWS == "*"

    msg := sprintf("IAM role '%s' can be assumed by any AWS account (*), which is a security risk", [resource.name])
}

# 🔐 Require MFA for sensitive IAM policies
deny contains msg if {
    some resource in input.planned_values.root_module.resources
    resource.type == "aws_iam_policy"

    policy_doc := json.unmarshal(resource.values.policy)
    some statement in policy_doc.Statement

    # Check for sensitive actions without MFA condition
    sensitive_actions := [
        "iam:CreateUser",
        "iam:DeleteUser",
        "iam:CreateRole",
        "iam:DeleteRole",
        "s3:DeleteBucket"
    ]

    some action in sensitive_actions
    action in statement.Action

    not statement.Condition["Bool"]["aws:MultiFactorAuthPresent"]

    msg := sprintf("IAM policy '%s' allows sensitive action '%s' without requiring MFA", [resource.name, action])
}

# ⚠️ Warn about overly broad S3 permissions
warn contains msg if {
    some resource in input.planned_values.root_module.resources
    resource.type == "aws_iam_policy"

    policy_doc := json.unmarshal(resource.values.policy)
    some statement in policy_doc.Statement

    "s3:*" in statement.Action
    statement.Resource == "arn:aws:s3:::*"

    msg := sprintf("IAM policy '%s' grants broad S3 permissions (s3:* on all buckets)", [resource.name])
}
EOF
```

### 🌐 Subtask 2.2: Create Security Group Policy

**1️⃣ Create a policy to enforce security group best practices:**
```rego
cat > policies/aws_security_groups.rego << 'EOF'
package terraform.aws.security_groups

import rego.v1

# 🚫 Deny security groups that allow unrestricted inbound access
deny contains msg if {
    some resource in input.planned_values.root_module.resources
    resource.type == "aws_security_group"

    some rule in resource.values.ingress
    rule.cidr_blocks[_] == "0.0.0.0/0"
    rule.from_port == 0
    rule.to_port == 65535

    msg := sprintf("Security group '%s' allows unrestricted inbound access (0.0.0.0/0 on all ports)", [resource.name])
}

# 🚫 Deny SSH access from anywhere
deny contains msg if {
    some resource in input.planned_values.root_module.resources
    resource.type == "aws_security_group"

    some rule in resource.values.ingress
    rule.cidr_blocks[_] == "0.0.0.0/0"
    rule.from_port <= 22
    rule.to_port >= 22

    msg := sprintf("Security group '%s' allows SSH access (port 22) from anywhere (0.0.0.0/0)", [resource.name])
}

# 🚫 Deny RDP access from anywhere
deny contains msg if {
    some resource in input.planned_values.root_module.resources
    resource.type == "aws_security_group"

    some rule in resource.values.ingress
    rule.cidr_blocks[_] == "0.0.0.0/0"
    rule.from_port <= 3389
    rule.to_port >= 3389

    msg := sprintf("Security group '%s' allows RDP access (port 3389) from anywhere (0.0.0.0/0)", [resource.name])
}

# 📝 Require description for security group rules
deny contains msg if {
    some resource in input.planned_values.root_module.resources
    resource.type == "aws_security_group"

    some rule in resource.values.ingress
    not rule.description

    msg := sprintf("Security group '%s' has ingress rule without description", [resource.name])
}

# ⚠️ Warn about commonly attacked ports open to the internet
warn contains msg if {
    some resource in input.planned_values.root_module.resources
    resource.type == "aws_security_group"

    some rule in resource.values.ingress
    rule.cidr_blocks[_] == "0.0.0.0/0"

    risky_ports := [21, 23, 135, 139, 445, 1433, 3306, 5432]
    some port in risky_ports
    rule.from_port <= port
    rule.to_port >= port

    msg := sprintf("Security group '%s' exposes potentially risky port %d to the internet", [resource.name, port])
}
EOF
```

### 🏷️ Subtask 2.3: Create Resource Tagging Policy

**1️⃣ Create a policy to enforce consistent resource tagging:**
```rego
cat > policies/aws_tagging.rego << 'EOF'
package terraform.aws.tagging

import rego.v1

# 🏷️ Required tags for all resources
required_tags := [
    "Environment",
    "Owner",
    "Project",
    "CostCenter"
]

# 📦 Resources that must be tagged
taggable_resources := [
    "aws_instance",
    "aws_s3_bucket",
    "aws_rds_instance",
    "aws_vpc",
    "aws_subnet",
    "aws_security_group"
]

# 🚫 Deny resources missing required tags
deny contains msg if {
    some resource in input.planned_values.root_module.resources
    resource.type in taggable_resources

    some required_tag in required_tags
    not resource.values.tags[required_tag]

    msg := sprintf("Resource '%s' of type '%s' is missing required tag '%s'", [resource.name, resource.type, required_tag])
}

# 🚫 Enforce tag value format for Environment
deny contains msg if {
    some resource in input.planned_values.root_module.resources
    resource.type in taggable_resources

    env_tag := resource.values.tags.Environment
    not env_tag in ["dev", "staging", "prod", "test"]

    msg := sprintf("Resource '%s' has invalid Environment tag value '%s'. Must be one of: dev, staging, prod, test", [resource.name, env_tag])
}

# ⚠️ Warn about resources with too many tags (potential overhead)
warn contains msg if {
    some resource in input.planned_values.root_module.resources
    resource.type in taggable_resources

    count(resource.values.tags) > 10

    msg := sprintf("Resource '%s' has %d tags, which may be excessive", [resource.name, count(resource.values.tags)])
}
EOF
```

> 🎓 **TODO:** Add a fourth policy file, `policies/aws_encryption.rego`, that denies any `aws_s3_bucket` or `aws_db_instance` resource missing an encryption-at-rest setting.

---

## 🔗 Task 3: Integrate OPA with Terraform for Security Checks

### 🚨 Subtask 3.1: Create Test Terraform Configuration

**1️⃣ Create a sample Terraform configuration that will violate some policies:**
```hcl
cat > terraform/main.tf << 'EOF'
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
  # For demo purposes - in real scenarios, use proper authentication
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
}

# 🚨 This IAM policy violates least privilege (wildcard permissions)
resource "aws_iam_policy" "bad_policy" {
  name = "overly-permissive-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "*"
        Resource = "*"
      }
    ]
  })
}

# 🚨 This IAM role can be assumed by anyone (security risk)
resource "aws_iam_role" "bad_role" {
  name = "insecure-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "*"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# 🚨 This security group allows unrestricted access
resource "aws_security_group" "bad_sg" {
  name_prefix = "insecure-sg"

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ⚠️ Missing required tags
}

# 🚨 This security group allows SSH from anywhere
resource "aws_security_group" "ssh_sg" {
  name_prefix = "ssh-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    # ⚠️ Missing description
  }

  tags = {
    Name = "SSH Security Group"
    # ⚠️ Missing required tags
  }
}

# ⚠️ This S3 bucket is missing required tags
resource "aws_s3_bucket" "example_bucket" {
  bucket = "my-example-bucket-${random_string.bucket_suffix.result}"

  tags = {
    Name = "Example Bucket"
    # Missing required tags: Environment, Owner, Project, CostCenter
  }
}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}
EOF
```

### ✅ Subtask 3.2: Create a Good Terraform Configuration

**1️⃣ Create a compliant Terraform configuration for comparison:**
```hcl
cat > terraform/main_compliant.tf << 'EOF'
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
  # For demo purposes - in real scenarios, use proper authentication
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
}

# ✅ Compliant IAM policy with specific permissions
resource "aws_iam_policy" "good_policy" {
  name = "least-privilege-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "arn:aws:s3:::my-specific-bucket/*"
      }
    ]
  })

  tags = {
    Environment = "dev"
    Owner       = "security-team"
    Project     = "compliance-demo"
    CostCenter  = "IT-001"
  }
}

# ✅ Compliant IAM role with specific principal
resource "aws_iam_role" "good_role" {
  name = "secure-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::123456789012:root"
        }
        Action = "sts:AssumeRole"
        Condition = {
          Bool = {
            "aws:MultiFactorAuthPresent" = "true"
          }
        }
      }
    ]
  })

  tags = {
    Environment = "prod"
    Owner       = "security-team"
    Project     = "compliance-demo"
    CostCenter  = "IT-001"
  }
}

# ✅ Compliant security group with restricted access
resource "aws_security_group" "good_sg" {
  name_prefix = "secure-sg"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "HTTPS access from internal network"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
    description = "SSH access from management subnet"
  }

  tags = {
    Name        = "Secure Security Group"
    Environment = "prod"
    Owner       = "network-team"
    Project     = "compliance-demo"
    CostCenter  = "IT-001"
  }
}

# ✅ Compliant S3 bucket with all required tags
resource "aws_s3_bucket" "compliant_bucket" {
  bucket = "compliant-bucket-${random_string.compliant_suffix.result}"

  tags = {
    Name        = "Compliant Bucket"
    Environment = "prod"
    Owner       = "data-team"
    Project     = "compliance-demo"
    CostCenter  = "IT-001"
  }
}

resource "random_string" "compliant_suffix" {
  length  = 8
  special = false
  upper   = false
}
EOF
```

### 🧾 Subtask 3.3: Create Conftest Configuration

**1️⃣ Create a configuration file for Conftest:**
```yaml
cat > conftest.yaml << 'EOF'
policy: ./policies
data: ./data
output: table
combine: false
trace: false
strict: false
EOF
```

### 🤖 Subtask 3.4: Create Policy Testing Script

**1️⃣ Create a script to automate the policy testing process:**
```bash
cat > test_policies.sh << 'EOF'
#!/bin/bash

set -e

echo "=== Policy as Code Security Testing ==="
echo

# 🔬 Function to test Terraform configuration against policies
test_terraform_config() {
    local config_file=$1
    local config_name=$2

    echo "Testing $config_name configuration..."
    echo "----------------------------------------"

    cd terraform

    # 🚀 Initialize Terraform
    terraform init -input=false > /dev/null 2>&1

    # 📄 Generate plan in JSON format
    terraform plan -out=tfplan -input=false > /dev/null 2>&1
    terraform show -json tfplan > plan.json

    cd ..

    # 🔍 Test against all policies
    echo "Running policy checks..."
    if conftest test --policy ./policies terraform/plan.json; then
        echo "✅ All policy checks passed for $config_name"
    else
        echo "❌ Policy violations found in $config_name"
    fi

    echo
    echo "Detailed policy evaluation:"
    conftest test --policy ./policies terraform/plan.json --output table || true

    echo
    echo "----------------------------------------"
    echo
}

# ❌ Test the non-compliant configuration
if [ -f "terraform/main.tf" ]; then
    test_terraform_config "main.tf" "Non-Compliant"
fi

# ✅ Test the compliant configuration
if [ -f "terraform/main_compliant.tf" ]; then
    # Temporarily rename files to test compliant version
    cd terraform
    if [ -f "main.tf" ]; then
        mv main.tf main_bad.tf
    fi
    mv main_compliant.tf main.tf
    cd ..

    test_terraform_config "main.tf" "Compliant"

    # Restore original files
    cd terraform
    mv main.tf main_compliant.tf
    if [ -f "main_bad.tf" ]; then
        mv main_bad.tf main.tf
    fi
    cd ..
fi

echo "=== Testing Complete ==="
EOF

chmod +x test_policies.sh
```

### 🌐 Subtask 3.5: Create OPA Server Integration Script

**1️⃣ Create a script to run OPA as a server for real-time policy evaluation:**
```bash
cat > opa_server.sh << 'EOF'
#!/bin/bash

set -e

echo "Starting OPA Server for Policy Evaluation..."

# 🚀 Start OPA server in the background
opa run --server --addr localhost:8181 ./policies &
OPA_PID=$!

echo "OPA Server started with PID: $OPA_PID"
echo "Server running at: http://localhost:8181"

# ⏳ Wait for server to start
sleep 3

# 🔬 Function to test policy via API
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

# 📝 Create a sample input for testing
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
EOF

chmod +x opa_server.sh
```

### ▶️ Subtask 3.6: Run Policy Tests

**1️⃣ Execute the policy testing to see violations and compliance:**
```bash
# 🚦 Run the comprehensive policy test
./test_policies.sh
```

### 🔬 Subtask 3.7: Test Individual Policies

**1️⃣ Test specific policies using OPA directly:**
```bash
# 🧩 Test IAM policy directly
cd terraform
terraform init -input=false
terraform plan -out=tfplan -input=false
terraform show -json tfplan > plan.json
cd ..

# 🔍 Test specific policy packages
echo "Testing IAM Least Privilege Policy:"
opa eval -d policies/ -i terraform/plan.json "data.terraform.aws.iam.deny"

echo
echo "Testing Security Group Policy:"
opa eval -d policies/ -i terraform/plan.json "data.terraform.aws.security_groups.deny"

echo
echo "Testing Tagging Policy:"
opa eval -d policies/ -i terraform/plan.json "data.terraform.aws.tagging.deny"
```

### 🔄 Subtask 3.8: Create CI/CD Integration Example

**1️⃣ Create a script that demonstrates how to integrate policy checks into a CI/CD pipeline:**
```bash
cat > cicd_integration.sh << 'EOF'
#!/bin/bash

set -e

echo "=== CI/CD Pipeline Policy Integration Demo ==="
echo

# 🌎 Simulate CI/CD environment variables
export ENVIRONMENT=${ENVIRONMENT:-"dev"}
export BRANCH_NAME=${BRANCH_NAME:-"feature/security-updates"}

echo "Environment: $ENVIRONMENT"
echo "Branch: $BRANCH_NAME"
echo

# 🔐 Function to run security checks
run_security_checks() {
    local exit_code=0

    echo "Step 1: Terraform Validation"
    cd terraform
    terraform fmt -check || { echo "❌ Terraform formatting issues found"; exit_code=1; }
    terraform validate || { echo "❌ Terraform validation failed"; exit_code=1; }
    echo "✅ Terraform validation passed"

    echo
    echo "Step 2: Generate Terraform Plan"
    terraform plan -out=tfplan -input=false
    terraform show -json tfplan > plan.json
    echo "✅ Terraform plan generated"

    cd ..

    echo
    echo "Step 3: Security Policy Checks"
    if conftest test --policy ./policies terraform/plan.json --output table; then
        echo "✅ All security policies passed"
    else
        echo "❌ Security policy violations found"
        exit_code=1
    fi

    echo
    echo "Step 4: Generate Security Report"
    conftest test --policy ./policies terraform/plan.json --output json > security_report.json
    echo "✅ Security report generated: security_report.json"

    return $exit_code
}

# 🚦 Run the security checks
if run_security_checks; then
    echo
    echo "🎉 All security checks passed! Ready for deployment."
    exit 0
else
    echo
    echo "🚫 Security checks failed! Deployment blocked."
    echo "Please fix the policy violations before proceeding."
    exit 1
fi
EOF

chmod +x cicd_integration.sh
```

### 🔁 Subtask 3.9: Test the CI/CD Integration

**1️⃣ Run the CI/CD integration script:**
```bash
# ❌ Test with the non-compliant configuration
./cicd_integration.sh

echo
echo "Now testing with compliant configuration..."

# 🔄 Switch to compliant configuration
cd terraform
mv main.tf main_bad.tf
mv main_compliant.tf main.tf
cd ..

# ✅ Test again
./cicd_integration.sh

# ↩️ Restore original configuration
cd terraform
mv main.tf main_compliant.tf
mv main_bad.tf main.tf
cd ..
```

> 🎓 **TODO:** Copy the `Policy Check` step from the GitHub Actions example in Subtask 3.10 into a real `.github/workflows/security-policy.yml` in one of your own repos and confirm it blocks a PR that reintroduces `main_bad.tf`.

### 📚 Subtask 3.10: Create Policy Documentation

**1️⃣ Generate documentation for the policies:**
```markdown
cat > POLICY_DOCUMENTATION.md << 'EOF'
# Security and Compliance Policies

## Overview

This document describes the security and compliance policies implemented using Open Policy Agent (OPA) for Terraform infrastructure as code.

## Policy Categories

### 1. IAM Least Privilege Policies

**File**: `policies/aws_iam_least_privilege.rego`

**Purpose**: Enforce least privilege access principles for AWS IAM resources.

**Rules**:
- **Deny wildcard permissions**: Prevents IAM policies with `*:*` permissions
- **Deny open role assumptions**: Prevents IAM roles that can be assumed by any AWS account
- **Require MFA for sensitive actions**: Enforces MFA for critical IAM operations
- **Warn about broad S3 permissions**: Alerts on overly permissive S3 access

### 2. Security Group Policies

**File**: `policies/aws_security_groups.rego`

**Purpose**: Enforce network security best practices for AWS security groups.

**Rules**:
- **Deny unrestricted inbound access**: Prevents security groups allowing all traffic from anywhere
- **Deny SSH from anywhere**: Blocks SSH access (port 22) from 0.0.0.0/0
- **Deny RDP from anywhere**: Blocks RDP access (port 3389) from 0.0.0.0/0
- **Require rule descriptions**: Enforces documentation for security group rules
- **Warn about risky ports**: Alerts when commonly attacked ports are exposed

### 3. Resource Tagging Policies

**File**: `policies/aws_tagging.rego`

**Purpose**: Enforce consistent resource tagging for cost management and governance.

**Rules**:
- **Required tags**: Enforces presence of Environment, Owner, Project, CostCenter tags
- **Environment tag validation**: Ensures Environment tag uses approved values
- **Tag count warning**: Alerts when resources have excessive tags

## Policy Testing

### Using Conftest

​```bash
# Test all policies against Terraform plan
conftest test --policy ./policies terraform/plan.json

# Test specific policy
conftest test --policy ./policies/aws_iam_least_privilege.rego terraform/plan.json
​```

### Using OPA CLI

​```bash
# Evaluate specific policy package
opa eval -d policies/ -i terraform/plan.json "data.terraform.aws.iam.deny"
​```

## Integration Examples

### CI/CD Pipeline Integration

​```yaml
# Example GitHub Actions workflow
name: Security Policy Check
on: [push, pull_request]

jobs:
  security-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v1
      - name: Install Conftest
        run: |
          wget https://github.com/open-policy-agent/conftest/releases/download/v0.46.0/conftest_0.46.0_Linux_x86_64.tar.gz
          tar -xzf conftest_0.46.0_Linux_x86_64.tar.gz
          sudo mv conftest /usr/local/bin/
      - name: Terraform Plan
        run: |
          terraform init
          terraform plan -out=tfplan
          terraform show -json tfplan > plan.json
      - name: Policy Check
        run: conftest test --policy ./policies plan.json
​```

## Policy Customization

### Adding New Policies
1. Create a new `.rego` file in the `policies/` directory
2. Define the package name following the convention: `terraform.aws.<service>`
3. Implement `deny` rules for violations and `warn` rules for recommendations
4. Test the policy using the provided testing scripts

### Modifying Existing Policies
1. Edit the relevant `.rego` file
2. Update the policy logic as needed
3. Test changes using `opa test` or `conftest test`
4. Update this documentation

EOF
```

---

## ✅ Verification and Testing

### 🔎 Verify All Components

Run a comprehensive verification of the lab setup:

```bash
# 📝 Create verification script
cat > verify_lab.sh << 'EOF'
#!/bin/bash

echo "=== Lab Verification ==="
echo

# 🔍 Check installed tools
echo "Checking installed tools..."
terraform version || echo "❌ Terraform not installed"
opa version || echo "❌ OPA not installed"
conftest --version || echo "❌ Conftest not installed"

echo
echo "Checking policy files..."
ls -la policies/

echo
echo "Checking Terraform configurations..."
ls -la terraform/

echo
echo "Running quick policy test..."
cd terraform
terraform init -input=false > /dev/null 2>&1
terraform plan -out=tfplan -input=false > /dev/null 2>&1
terraform show -json tfplan > plan.json
cd ..

conftest test --policy ./policies terraform/plan.json --output table

echo
echo "=== Verification Complete ==="
EOF

chmod +x verify_lab.sh
./verify_lab.sh
```

---

## 🛠️ Troubleshooting Common Issues

<details>
<summary>❗ Policy not found</summary>

Ensure the policy file is in the correct directory and has the right package name.
</details>

<details>
<summary>❗ JSON parsing errors</summary>

Verify the Terraform plan JSON format is correct (regenerate `plan.json` via `terraform show -json tfplan > plan.json` if in doubt).
</details>

<details>
<summary>❗ Rule not triggering</summary>

Check the resource type and attribute paths in the policy — Rego rules only fire when every condition in the rule body matches exactly.
</details>

<details>
<summary>💡 Debugging Tips</summary>

- Use `opa fmt` to format policy files
- Use `opa test` to run unit tests for policies
- Enable trace mode in Conftest for detailed evaluation: `conftest test --trace`
</details>

---

## 🗺️ MITRE ATT&CK Mapping

| Technique ID | Technique Name | Policy Control |
|---------------|-----------------|-----------------|
| T1190 | Exploit Public-Facing Application | Deny rule blocking security groups with unrestricted inbound access (0.0.0.0/0 on all ports) |
| T1021.004 | Remote Services: SSH | Deny rule blocking SSH (port 22) exposure to 0.0.0.0/0 |
| T1021.001 | Remote Services: Remote Desktop Protocol | Deny rule blocking RDP (port 3389) exposure to 0.0.0.0/0 |
| T1078.004 | Valid Accounts: Cloud Accounts | Deny rule blocking IAM roles assumable by any AWS account (`Principal.AWS = "*"`) |
| T1098 | Account Manipulation | Deny rule blocking IAM policies with wildcard (`*:*`) permissions |
| T1556 | Modify Authentication Process | Deny rule requiring MFA condition on sensitive IAM actions (CreateUser, DeleteRole, etc.) |

---

## 🧠 Key Concepts

| Concept | Tool / Technique | Purpose |
|---------|-------------------|---------|
| 📜 Policy as Code | Rego + OPA | Expresses security/compliance rules as version-controlled, testable code instead of manual review |
| 🧪 Structured Config Testing | Conftest | Tests Terraform plan JSON (and other structured config) against Rego policies |
| ⬅️ Shift-Left Security | OPA + `terraform plan` (pre-apply) | Catches violations during planning, before any resource is ever created |
| 🚦 Deny vs. Warn | Rego `deny`/`warn` rules | Separates hard blockers (deny) from advisory findings (warn) in the same policy set |
| 🔄 CI/CD Gatekeeping | `cicd_integration.sh` + GitHub Actions example | Blocks merges/deploys automatically when `conftest test` fails |
| 🌐 Real-Time Evaluation | `opa run --server` + REST API | Lets other services query policy decisions live, not just at plan-time |
| 🏷️ Governance Tagging | `aws_tagging.rego` | Enforces cost-center/ownership/environment metadata across resources |

---

## 🏁 Conclusion

> ⚠️ **Note:** The source lab content ends mid-sentence under a **"Why This Matters"** heading immediately after the Conclusion's accomplishment list, with no further text supplied. The sections below reflect only what the lab material explicitly states — no continuation has been invented.

In this comprehensive lab, you have successfully:

- ✅ Installed and configured **Open Policy Agent (OPA)** on a Linux system, along with supporting tools like **Conftest** for policy testing and validation
- ✅ Created comprehensive security policies using the **Rego** language to enforce:
  - Least privilege access for IAM policies and roles
  - Network security best practices for security groups
  - Consistent resource tagging for governance and cost management
- ✅ Integrated OPA with Terraform workflows to perform automated security checks during the infrastructure planning phase, implementing a **"shift-left"** security approach
- ✅ Developed automation scripts for CI/CD pipeline integration, demonstrating how policy-as-code can be embedded into development workflows to catch security issues early
- ✅ Implemented real-time policy evaluation using **OPA server mode** for interactive policy testing and validation

### 🌍 Real-World Applications

Enforcing these controls as code — rather than through manual review — means every IAM policy, security group, and tagging decision is checked automatically and consistently, before it ever reaches production. Teams get the same "shift-left" benefit they expect from linting and unit tests, applied directly to cloud security and compliance posture: violations are caught in the pull request, not in an incident report.

---

<div align="center">

![Al Nafi](https://img.shields.io/badge/Al%20Nafi-Cybersecurity%20Training-blueviolet?style=for-the-badge)

</div>
