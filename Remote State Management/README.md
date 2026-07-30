<div align="center">

# ☁️ Remote State Management

### S3 Remote Backends with DynamoDB State Locking

![Terraform](https://img.shields.io/badge/Terraform-844FBA?style=for-the-badge&logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazonaws&logoColor=white)
![S3](https://img.shields.io/badge/Amazon%20S3-569A31?style=for-the-badge&logo=amazons3&logoColor=white)
![DynamoDB](https://img.shields.io/badge/DynamoDB-4053D6?style=for-the-badge&logo=amazondynamodb&logoColor=white)
![Bash](https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white)

**Difficulty:** 🟡 Intermediate &nbsp;|&nbsp; **Duration:** ⏱️ 120–150 minutes &nbsp;|&nbsp; **Track:** ☁️ Cloud DevOps

</div>

---

## 📑 Table of Contents

- [🎯 Lab Objectives](#-lab-objectives)
- [📋 Prerequisites](#-prerequisites)
- [🖥️ Lab Environment](#️-lab-environment)
- [🧰 Task 1: Environment Setup and Tool Installation](#-task-1-environment-setup-and-tool-installation)
- [🪣 Task 2: Configure S3 Bucket as Remote Backend](#-task-2-configure-s3-bucket-as-remote-backend)
- [🔒 Task 3: Implement State Locking Using DynamoDB](#-task-3-implement-state-locking-using-dynamodb)
- [🗂️ Task 4: Set Up Versioning and Backup for Terraform State](#️-task-4-set-up-versioning-and-backup-for-terraform-state)
- [🧠 Task 5: Advanced Remote State Management](#-task-5-advanced-remote-state-management)
- [🧹 Task 6: Cleanup and Resource Management](#-task-6-cleanup-and-resource-management)
- [🛠️ Troubleshooting Guide](#️-troubleshooting-guide)
- [✅ Lab Verification](#-lab-verification)
- [🧠 Key Concepts](#-key-concepts)
- [🏁 Conclusion](#-conclusion)

---

## 🎯 Lab Objectives

By the end of this lab, you will be able to:

| # | Objective |
|---|-----------|
| 1 | 🪣 Configure an Amazon S3 bucket as a remote backend for Terraform state management |
| 2 | 🔒 Implement state locking using Amazon DynamoDB to prevent concurrent modifications |
| 3 | 🗂️ Set up versioning and backup strategies for Terraform state files |
| 4 | 📚 Understand the benefits and best practices of remote state management |
| 5 | 🛠️ Troubleshoot common issues with remote state configuration |

---

## 📋 Prerequisites

| Requirement | Details |
|---|---|
| 🧩 Terraform Basics | Basic understanding of Terraform concepts and syntax |
| ☁️ AWS Services | Familiarity with S3, DynamoDB, and IAM |
| 🐧 Linux CLI | Knowledge of Linux command line operations |
| 📝 JSON / HCL | Understanding of JSON and HashiCorp Configuration Language syntax |
| 🔀 Version Control | Basic knowledge of version control concepts |

---

## 🖥️ Lab Environment

> 💡 **Note:** Al Nafi provides Linux-based cloud machines for this lab. Simply click **Start Lab** to access your dedicated Linux machine. The machine is bare metal with no pre-installed tools — you will install all required tools during the lab exercises.

![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?style=flat-square&logo=ubuntu&logoColor=white)

---

## 🧰 Task 1: Environment Setup and Tool Installation

![Terraform](https://img.shields.io/badge/Terraform-844FBA?style=flat-square&logo=terraform&logoColor=white)
![AWS%20CLI](https://img.shields.io/badge/AWS%20CLI-232F3E?style=flat-square&logo=amazonaws&logoColor=white)
![jq](https://img.shields.io/badge/jq-000000?style=flat-square&logo=json&logoColor=white)

### ⬇️ Subtask 1.1: Install Required Tools

```bash
# 🔄 Update the system packages
sudo apt update && sudo apt upgrade -y

# 📦 Install required dependencies
sudo apt install -y wget unzip curl gnupg software-properties-common

# ⬇️ Install Terraform
wget https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_linux_amd64.zip
# TODO: Check releases.hashicorp.com/terraform for the current latest version before downloading
unzip terraform_1.6.6_linux_amd64.zip
sudo mv terraform /usr/local/bin/
terraform version

# ⬇️ Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws --version

# ⬇️ Install jq for JSON processing
sudo apt install -y jq
```

### 🔑 Subtask 1.2: Configure AWS Credentials

> 💡 For this lab, we'll use environment variables to hold AWS credentials.

```bash
# 📂 Create AWS credentials directory
mkdir -p ~/.aws

# 🔑 Set up AWS credentials (replace with your actual credentials)
export AWS_ACCESS_KEY_ID="your-access-key-id"
export AWS_SECRET_ACCESS_KEY="your-secret-access-key"
export AWS_DEFAULT_REGION="us-east-1"
# TODO: Replace the placeholder access key and secret key with your own AWS IAM credentials

# ✅ Verify AWS configuration
aws sts get-caller-identity
```

### 📂 Subtask 1.3: Create Project Directory Structure

```bash
# 📁 Create project directory
mkdir -p ~/terraform-remote-state-lab
cd ~/terraform-remote-state-lab

# 🗄️ Create subdirectories for organization
mkdir -p {backend-setup,main-infrastructure,scripts}

# 📄 Create initial files
touch backend-setup/backend.tf
touch backend-setup/variables.tf
touch main-infrastructure/main.tf
touch main-infrastructure/backend.tf
touch scripts/cleanup.sh
```

> 🟢 **Sign-off:** Toolchain installed, AWS credentials verified, and project scaffolding created.

---

## 🪣 Task 2: Configure S3 Bucket as Remote Backend

![S3](https://img.shields.io/badge/Amazon%20S3-569A31?style=flat-square&logo=amazons3&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-844FBA?style=flat-square&logo=terraform&logoColor=white)

### 🏗️ Subtask 2.1: Create S3 Bucket for State Storage

```bash
# 📍 Navigate to backend setup directory
cd ~/terraform-remote-state-lab/backend-setup

# ✍️ Create variables file
cat > variables.tf << 'EOF'
variable "bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  type        = string
  default     = "terraform-state-bucket-unique-12345"
}
# TODO: Change bucket_name to a globally unique value before applying

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "lab"
}
EOF

# ✍️ Create backend setup configuration
cat > backend.tf << 'EOF'
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# 🪣 S3 bucket for storing Terraform state
resource "aws_s3_bucket" "terraform_state" {
  bucket = var.bucket_name

  tags = {
    Name        = "Terraform State Bucket"
    Environment = var.environment
    Purpose     = "Remote State Storage"
  }
}

# 🔁 Enable versioning on the S3 bucket
resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# 🔐 Enable server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_encryption" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# 🚫 Block public access to the bucket
resource "aws_s3_bucket_public_access_block" "terraform_state_pab" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 📤 Output the bucket name for reference
output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.terraform_state.arn
}
EOF
```

### 🚀 Subtask 2.2: Deploy S3 Backend Infrastructure

```bash
# ⚙️ Initialize Terraform
terraform init

# 🗺️ Plan the deployment
terraform plan

# 🚀 Apply the configuration
terraform apply -auto-approve

# 💾 Save the bucket name for later use
BUCKET_NAME=$(terraform output -raw s3_bucket_name)
echo "S3_BUCKET_NAME=$BUCKET_NAME" > ../bucket_info.env
echo "Bucket created: $BUCKET_NAME"
```

> 🟢 **Sign-off:** Versioned, encrypted, public-access-blocked S3 bucket deployed for state storage.

---

## 🔒 Task 3: Implement State Locking Using DynamoDB

![DynamoDB](https://img.shields.io/badge/DynamoDB-4053D6?style=flat-square&logo=amazondynamodb&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-844FBA?style=flat-square&logo=terraform&logoColor=white)

### 🗃️ Subtask 3.1: Create DynamoDB Table for State Locking

```bash
# ➕ Append DynamoDB configuration to backend.tf
cat >> backend.tf << 'EOF'

# 🔒 DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "terraform-state-lock-${var.environment}"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform State Lock Table"
    Environment = var.environment
    Purpose     = "State Locking"
  }
}

# 📤 Output the DynamoDB table name
output "dynamodb_table_name" {
  description = "Name of the DynamoDB table for state locking"
  value       = aws_dynamodb_table.terraform_state_lock.name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table for state locking"
  value       = aws_dynamodb_table.terraform_state_lock.arn
}
EOF
```

### 🚀 Subtask 3.2: Apply DynamoDB Configuration

```bash
# 🗺️ Apply the updated configuration
terraform plan
terraform apply -auto-approve

# 💾 Save the DynamoDB table name
DYNAMODB_TABLE=$(terraform output -raw dynamodb_table_name)
echo "DYNAMODB_TABLE_NAME=$DYNAMODB_TABLE" >> ../bucket_info.env
echo "DynamoDB table created: $DYNAMODB_TABLE"
```

### 🔍 Subtask 3.3: Verify Backend Resources

```bash
# ✅ Verify S3 bucket exists and has versioning enabled
aws s3api get-bucket-versioning --bucket $BUCKET_NAME

# ✅ Verify DynamoDB table exists
aws dynamodb describe-table --table-name $DYNAMODB_TABLE --query 'Table.{Name:TableName,Status:TableStatus,KeySchema:KeySchema}'

# 👀 List S3 bucket contents (should be empty initially)
aws s3 ls s3://$BUCKET_NAME/
```

> 🟢 **Sign-off:** DynamoDB lock table provisioned and verified alongside the S3 backend.

---

## 🗂️ Task 4: Set Up Versioning and Backup for Terraform State

![S3](https://img.shields.io/badge/Amazon%20S3-569A31?style=flat-square&logo=amazons3&logoColor=white)
![VPC](https://img.shields.io/badge/Amazon%20VPC-8C4FFF?style=flat-square&logo=amazonaws&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-844FBA?style=flat-square&logo=terraform&logoColor=white)

### ⚙️ Subtask 4.1: Configure Remote Backend for Main Infrastructure

```bash
# 📍 Navigate to main infrastructure directory
cd ~/terraform-remote-state-lab/main-infrastructure

# 📥 Source the bucket information
source ../bucket_info.env

# ✍️ Create backend configuration
cat > backend.tf << EOF
terraform {
  backend "s3" {
    bucket         = "$S3_BUCKET_NAME"
    key            = "infrastructure/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "$DYNAMODB_TABLE_NAME"
    encrypt        = true
  }
}
EOF

# ✍️ Create main infrastructure configuration
cat > main.tf << 'EOF'
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# 🌐 Example infrastructure - VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "Main VPC"
    Environment = "lab"
    ManagedBy   = "Terraform"
  }
}

# 🧩 Example infrastructure - Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name        = "Public Subnet"
    Environment = "lab"
    ManagedBy   = "Terraform"
  }
}

# 🚪 Example infrastructure - Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "Main IGW"
    Environment = "lab"
    ManagedBy   = "Terraform"
  }
}

# 📤 Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}
EOF
```

### 🚀 Subtask 4.2: Initialize and Apply with Remote Backend

```bash
# ⚙️ Initialize Terraform with remote backend
terraform init

# 🔍 Verify backend configuration
terraform show

# 🗺️ Plan and apply the infrastructure
terraform plan
terraform apply -auto-approve
```

### ✅ Subtask 4.3: Verify Remote State Storage

```bash
# 👀 Check that state file is stored in S3
aws s3 ls s3://$S3_BUCKET_NAME/infrastructure/

# 🔬 Get detailed information about the state file
aws s3api head-object --bucket $S3_BUCKET_NAME --key infrastructure/terraform.tfstate

# 🔒 Check DynamoDB for lock information (should be empty when not locked)
aws dynamodb scan --table-name $DYNAMODB_TABLE_NAME
```

### 🔐 Subtask 4.4: Test State Locking

```bash
# 🧪 Create a test script for state locking
cat > ../scripts/test_locking.sh << 'EOF'
#!/bin/bash

echo "Testing Terraform state locking..."

# Start a long-running terraform operation in background
terraform plan -detailed-exitcode &
PLAN_PID=$!

# Wait a moment for the lock to be acquired
sleep 2

# Try to run another terraform command (should fail due to lock)
echo "Attempting second terraform operation (should fail)..."
timeout 10 terraform plan

# Wait for the first operation to complete
wait $PLAN_PID

echo "First operation completed. Lock should be released."

# Try the second operation again (should succeed now)
echo "Attempting second terraform operation again (should succeed)..."
terraform plan

echo "State locking test completed."
EOF

chmod +x ../scripts/test_locking.sh

# ▶️ Run the locking test
../scripts/test_locking.sh
```

### 💾 Subtask 4.5: Implement State Backup Strategy

```bash
# 🧪 Create backup script
cat > ../scripts/backup_state.sh << 'EOF'
#!/bin/bash

# Load environment variables
source ../bucket_info.env

BACKUP_DIR="$HOME/terraform-state-backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Create backup directory
mkdir -p $BACKUP_DIR

echo "Creating state backup..."

# Download current state file
aws s3 cp s3://$S3_BUCKET_NAME/infrastructure/terraform.tfstate $BACKUP_DIR/terraform.tfstate.$TIMESTAMP

# List all versions of the state file in S3
echo "Available state file versions:"
aws s3api list-object-versions --bucket $S3_BUCKET_NAME --prefix infrastructure/terraform.tfstate

# Create a local backup of the entire state bucket
echo "Creating full bucket backup..."
aws s3 sync s3://$S3_BUCKET_NAME $BACKUP_DIR/full_backup_$TIMESTAMP/

echo "Backup completed. Files saved to: $BACKUP_DIR"
ls -la $BACKUP_DIR/
EOF

chmod +x ../scripts/backup_state.sh

# ▶️ Run the backup script
../scripts/backup_state.sh
```

### 🆘 Subtask 4.6: Test State Recovery

```bash
# 🧪 Create a recovery test script
cat > ../scripts/test_recovery.sh << 'EOF'
#!/bin/bash

source ../bucket_info.env

echo "Testing state recovery..."

# Make a change to test recovery
terraform apply -auto-approve

# Create a backup before making destructive changes
aws s3 cp s3://$S3_BUCKET_NAME/infrastructure/terraform.tfstate ./state_backup_before_test.json

# Simulate state corruption by uploading invalid state
echo '{"invalid": "state"}' > ./corrupted_state.json
aws s3 cp ./corrupted_state.json s3://$S3_BUCKET_NAME/infrastructure/terraform.tfstate

# Try to run terraform (should fail)
echo "Testing with corrupted state (should fail)..."
terraform plan || echo "Expected failure due to corrupted state"

# Restore from backup
echo "Restoring from backup..."
aws s3 cp ./state_backup_before_test.json s3://$S3_BUCKET_NAME/infrastructure/terraform.tfstate

# Verify recovery
echo "Testing after recovery (should succeed)..."
terraform plan

echo "Recovery test completed successfully."

# Cleanup test files
rm -f ./corrupted_state.json ./state_backup_before_test.json
EOF

chmod +x ../scripts/test_recovery.sh

# ▶️ Run the recovery test
../scripts/test_recovery.sh
```

> 🟢 **Sign-off:** Remote-backed infrastructure applied, with locking, versioned backups, and corruption recovery all tested.

---

## 🧠 Task 5: Advanced Remote State Management

![S3](https://img.shields.io/badge/Amazon%20S3-569A31?style=flat-square&logo=amazons3&logoColor=white)
![Bash](https://img.shields.io/badge/Bash-4EAA25?style=flat-square&logo=gnubash&logoColor=white)

### 🔐 Subtask 5.1: Implement State File Encryption Verification

```bash
# 🧪 Create encryption verification script
cat > ../scripts/verify_encryption.sh << 'EOF'
#!/bin/bash

source ../bucket_info.env

echo "Verifying state file encryption..."

# Check bucket encryption configuration
echo "S3 Bucket Encryption Configuration:"
aws s3api get-bucket-encryption --bucket $S3_BUCKET_NAME

# Check if state file is encrypted
echo "State file encryption status:"
aws s3api head-object --bucket $S3_BUCKET_NAME --key infrastructure/terraform.tfstate --query 'ServerSideEncryption'

# Verify bucket versioning is enabled
echo "Bucket versioning status:"
aws s3api get-bucket-versioning --bucket $S3_BUCKET_NAME

echo "Encryption verification completed."
EOF

chmod +x ../scripts/verify_encryption.sh
../scripts/verify_encryption.sh
```

### 🔀 Subtask 5.2: Create State Migration Script

```bash
# 🧪 Create state migration script for future use
cat > ../scripts/migrate_state.sh << 'EOF'
#!/bin/bash

echo "State Migration Script"
echo "This script demonstrates how to migrate state between backends"

# Create a local backend configuration for comparison
cat > backend_local.tf << 'LOCALEOF'
terraform {
  backend "local" {
    path = "./terraform.tfstate.local"
  }
}
LOCALEOF

echo "To migrate from remote to local backend:"
echo "1. Replace backend.tf with backend_local.tf"
echo "2. Run: terraform init -migrate-state"
echo "3. Confirm the migration when prompted"

echo "To migrate back to remote backend:"
echo "1. Replace backend_local.tf with the original backend.tf"
echo "2. Run: terraform init -migrate-state"
echo "3. Confirm the migration when prompted"

echo "Migration script prepared. Use with caution in production!"
EOF

chmod +x ../scripts/migrate_state.sh
```

### 📊 Subtask 5.3: Monitor State File Changes

```bash
# 🧪 Create monitoring script
cat > ../scripts/monitor_state.sh << 'EOF'
#!/bin/bash

source ../bucket_info.env

echo "Monitoring Terraform state changes..."

# Function to get state file info
get_state_info() {
    aws s3api head-object --bucket $S3_BUCKET_NAME --key infrastructure/terraform.tfstate --query '{LastModified:LastModified,ETag:ETag,Size:ContentLength}' 2>/dev/null || echo "State file not found"
}

# Get initial state
echo "Initial state file info:"
INITIAL_STATE=$(get_state_info)
echo $INITIAL_STATE

# Make a small change to trigger state update
echo "Making infrastructure change..."
terraform apply -auto-approve

# Check state after change
echo "State file info after change:"
UPDATED_STATE=$(get_state_info)
echo $UPDATED_STATE

# Compare states
if [ "$INITIAL_STATE" != "$UPDATED_STATE" ]; then
    echo "State file has been updated successfully!"
else
    echo "No changes detected in state file."
fi

# Show version history
echo "State file version history:"
aws s3api list-object-versions --bucket $S3_BUCKET_NAME --prefix infrastructure/terraform.tfstate --query 'Versions[*].{Key:Key,VersionId:VersionId,LastModified:LastModified,Size:Size}' --output table

echo "Monitoring completed."
EOF

chmod +x ../scripts/monitor_state.sh
../scripts/monitor_state.sh
```

> 🟢 **Sign-off:** Encryption verified, a backend-migration playbook prepared, and state-change monitoring in place.

---

## 🧹 Task 6: Cleanup and Resource Management

![AWS](https://img.shields.io/badge/AWS-232F3E?style=flat-square&logo=amazonaws&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-844FBA?style=flat-square&logo=terraform&logoColor=white)

### 🧹 Subtask 6.1: Create Comprehensive Cleanup Script

```bash
# 🧪 Create cleanup script
cat > ../scripts/cleanup.sh << 'EOF'
#!/bin/bash

source ../bucket_info.env

echo "Starting cleanup process..."

# Navigate to main infrastructure directory
cd ~/terraform-remote-state-lab/main-infrastructure

# Destroy main infrastructure
echo "Destroying main infrastructure..."
terraform destroy -auto-approve

# Navigate to backend setup directory
cd ~/terraform-remote-state-lab/backend-setup

# Empty S3 bucket before destroying (required for bucket deletion)
echo "Emptying S3 bucket..."
aws s3 rm s3://$S3_BUCKET_NAME --recursive

# Delete all versions of objects in the bucket
echo "Deleting all object versions..."
aws s3api list-object-versions --bucket $S3_BUCKET_NAME --query 'Versions[].{Key:Key,VersionId:VersionId}' --output text | while read key version; do
    if [ "$key" != "None" ] && [ "$version" != "None" ]; then
        aws s3api delete-object --bucket $S3_BUCKET_NAME --key "$key" --version-id "$version"
    fi
done

# Delete all delete markers
aws s3api list-object-versions --bucket $S3_BUCKET_NAME --query 'DeleteMarkers[].{Key:Key,VersionId:VersionId}' --output text | while read key version; do
    if [ "$key" != "None" ] && [ "$version" != "None" ]; then
        aws s3api delete-object --bucket $S3_BUCKET_NAME --key "$key" --version-id "$version"
    fi
done

# Destroy backend infrastructure
echo "Destroying backend infrastructure..."
terraform destroy -auto-approve

# Clean up local files
echo "Cleaning up local files..."
cd ~/terraform-remote-state-lab
rm -rf terraform-state-backups/
rm -f bucket_info.env

echo "Cleanup completed successfully!"
EOF

chmod +x ../scripts/cleanup.sh
```

### 🔍 Subtask 6.2: Verify Current State Before Cleanup

```bash
# 👀 Show current resources before cleanup
echo "Current AWS resources created in this lab:"

# 🪣 List S3 buckets
echo "S3 Buckets:"
aws s3 ls | grep terraform-state

# 🔒 List DynamoDB tables
echo "DynamoDB Tables:"
aws dynamodb list-tables --query 'TableNames[?contains(@, `terraform-state-lock`)]'

# 🌐 Show VPC resources
echo "VPC Resources:"
aws ec2 describe-vpcs --filters "Name=tag:ManagedBy,Values=Terraform" --query 'Vpcs[*].{VpcId:VpcId,CidrBlock:CidrBlock,Tags:Tags}'
```

> ⚠️ Run `../scripts/cleanup.sh` when you're finished with the lab to avoid ongoing AWS charges.

> 🟢 **Sign-off:** All lab resources inventoried and a full teardown script prepared for safe cleanup.

---

## 🛠️ Troubleshooting Guide

<details>
<summary>❌ Issue 1: Backend initialization fails</summary>

```bash
# Solution: Check AWS credentials and permissions
aws sts get-caller-identity
aws s3 ls  # Test S3 access
aws dynamodb list-tables  # Test DynamoDB access
```
</details>

<details>
<summary>❌ Issue 2: State locking timeout</summary>

```bash
# Solution: Force unlock if necessary (use with caution)
terraform force-unlock LOCK_ID

# Check for stuck locks in DynamoDB
aws dynamodb scan --table-name $DYNAMODB_TABLE_NAME
```
</details>

<details>
<summary>❌ Issue 3: State file corruption</summary>

```bash
# Solution: Restore from S3 version or backup
aws s3api list-object-versions --bucket $S3_BUCKET_NAME --prefix infrastructure/terraform.tfstate

# Restore specific version
aws s3api get-object --bucket $S3_BUCKET_NAME --key infrastructure/terraform.tfstate --version-id VERSION_ID terraform.tfstate.restored
```
</details>

<details>
<summary>❌ Issue 4: Permission denied errors</summary>

```bash
# Solution: Check IAM permissions for S3 and DynamoDB
aws iam simulate-principal-policy --policy-source-arn $(aws sts get-caller-identity --query Arn --output text) --action-names s3:GetObject s3:PutObject dynamodb:GetItem dynamodb:PutItem --resource-arns "arn:aws:s3:::$S3_BUCKET_NAME/*" "arn:aws:dynamodb:us-east-1:*:table/$DYNAMODB_TABLE_NAME"
```
</details>

---

## ✅ Lab Verification

### 🪣 S3 Backend Configuration

- [ ] S3 bucket created with versioning enabled
- [ ] Bucket encryption configured
- [ ] Public access blocked
- [ ] State file successfully stored in S3

### 🔒 DynamoDB State Locking

- [ ] DynamoDB table created with correct schema
- [ ] State locking works during concurrent operations
- [ ] Lock is automatically released after operations

### 🗂️ State Management

- [ ] Remote state properly initialized
- [ ] State changes reflected in S3
- [ ] Version history maintained
- [ ] Backup and recovery procedures tested

### 🔐 Security and Best Practices

- [ ] State file encrypted at rest
- [ ] Access controls properly configured
- [ ] Backup strategy implemented
- [ ] Monitoring capabilities established

---

## 🧠 Key Concepts

| Concept | Description |
|---|---|
| ☁️ S3 Remote Backend | Centralizes Terraform state in a versioned, encrypted S3 bucket instead of a local file |
| 🔒 DynamoDB State Locking | A `LockID`-keyed table that prevents two `terraform apply` runs from corrupting state concurrently |
| 🔁 Versioning & Backup | S3 object versioning plus scripted backups provide rollback points if state is corrupted |
| 🔐 Encryption at Rest | Server-side encryption (AES256) keeps the state file — which may contain sensitive attributes — protected in storage |
| 🔀 State Migration | `terraform init -migrate-state` moves state between backend types (e.g., local ↔ S3) |
| 📊 State Monitoring | Comparing `LastModified`/`ETag` metadata over time detects unexpected or unauthorized state changes |

---

## 🏁 Conclusion

In this lab, you have successfully implemented a comprehensive remote state management solution for Terraform using AWS S3 and DynamoDB. You have learned how to:

- ☁️ Configure S3 as a remote backend for centralized state storage with versioning and encryption
- 🔒 Implement state locking using DynamoDB to prevent concurrent modifications and state corruption
- 💾 Set up backup and recovery procedures to protect against data loss
- 📊 Monitor and manage state files effectively in a team environment
- 🛠️ Troubleshoot common issues related to remote state management

### 🌍 Why This Matters

Remote state management is crucial for production Terraform deployments because it:

- 👥 Enables team collaboration by providing a centralized state store
- 🔒 Prevents state conflicts through locking mechanisms
- 🔁 Provides state history and rollback capabilities through versioning
- 🔐 Ensures state security through encryption and access controls
- 🆘 Enables disaster recovery through backup strategies

These skills are essential for managing infrastructure as code in enterprise environments where multiple team members need to collaborate on infrastructure changes safely and efficiently. The remote state management patterns learned in this lab form the foundation for advanced Terraform workflows including CI/CD pipelines, multi-environment deployments, and large-scale infrastructure management.

---

<div align="center">

![Al Nafi](https://img.shields.io/badge/Al%20Nafi-Cybersecurity%20Training-blueviolet?style=for-the-badge)

</div>
