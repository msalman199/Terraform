<div align="center">

# 🔌 Provider Configuration

### Configuring the AWS Provider in Terraform with Secure Credential Management

![Terraform](https://img.shields.io/badge/Terraform-844FBA?style=for-the-badge&logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazonaws&logoColor=white)
![S3](https://img.shields.io/badge/Amazon%20S3-569A31?style=for-the-badge&logo=amazons3&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Bash](https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white)

**Difficulty:** 🟢 Beginner &nbsp;|&nbsp; **Duration:** ⏱️ 60–90 minutes &nbsp;|&nbsp; **Track:** ☁️ Cloud DevOps

</div>

---

## 📑 Table of Contents

- [🎯 Lab Objectives](#-lab-objectives)
- [📋 Prerequisites](#-prerequisites)
- [🖥️ Lab Environment](#️-lab-environment)
- [🧰 Task 1: Install Required Tools](#-task-1-install-required-tools)
- [🔑 Task 2: Set Up AWS Credentials Using Environment Variables](#-task-2-set-up-aws-credentials-using-environment-variables)
- [⚙️ Task 3: Configure AWS Provider in Terraform](#️-task-3-configure-aws-provider-in-terraform)
- [🪣 Task 4: Create S3 Bucket Configuration](#-task-4-create-s3-bucket-configuration)
- [🚀 Task 5: Initialize and Deploy Terraform Configuration](#-task-5-initialize-and-deploy-terraform-configuration)
- [🧹 Task 6: Manage and Clean Up Resources](#-task-6-manage-and-clean-up-resources)
- [🛠️ Troubleshooting Tips](#️-troubleshooting-tips)
- [🧠 Key Concepts Learned](#-key-concepts-learned)
- [✅ Conclusion](#-conclusion)

---

## 🎯 Lab Objectives

By the end of this lab, you will be able to:

| # | Objective |
|---|-----------|
| 1 | 🔌 Configure the AWS provider in Terraform with proper authentication |
| 2 | 🔑 Set up AWS credentials using environment variables for secure access |
| 3 | 📝 Create and manage basic Terraform configuration files |
| 4 | 🪣 Provision AWS resources (S3 bucket) using Terraform |
| 5 | ✅ Understand best practices for provider configuration and credential management |
| 6 | ▶️ Execute Terraform commands to initialize, plan, and apply infrastructure changes |

---

## 📋 Prerequisites

| Requirement | Details |
|---|---|
| ☁️ Cloud Concepts | Basic understanding of cloud computing concepts |
| 🐧 Linux CLI | Familiarity with Linux command line operations |
| 📝 Text Editors | Basic knowledge of `nano`, `vim`, or similar |
| 🪣 AWS Services | Understanding of AWS services (specifically S3) |
| 🌍 Prior Knowledge | Completion of previous Terraform basics labs or equivalent knowledge |

---

## 🖥️ Lab Environment

> 💡 **Note:** Al Nafi provides Linux-based cloud machines for this lab. Simply click **Start Lab** to access your dedicated Linux machine. The machine is bare metal with no pre-installed tools — you will install all required tools during the lab exercises.

![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?style=flat-square&logo=ubuntu&logoColor=white)

---

## 🧰 Task 1: Install Required Tools

![Terraform](https://img.shields.io/badge/Terraform-844FBA?style=flat-square&logo=terraform&logoColor=white)
![AWS%20CLI](https://img.shields.io/badge/AWS%20CLI-232F3E?style=flat-square&logo=amazonaws&logoColor=white)
![APT](https://img.shields.io/badge/APT-A81D33?style=flat-square&logo=debian&logoColor=white)

### ⬇️ Subtask 1.1: Install Terraform

```bash
# 🔄 Update the system package list
sudo apt update

# 📦 Install required packages
sudo apt install -y gnupg software-properties-common curl

# 🔐 Add HashiCorp GPG key
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -

# 📡 Add HashiCorp repository
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

# 🔄 Update package list again
sudo apt update

# ⬇️ Install Terraform
sudo apt install terraform

# ✅ Verify installation
terraform version
```

### 🔎 Subtask 1.2: Install AWS CLI (Optional but Recommended)

> 💡 While not strictly required for this lab, AWS CLI helps with credential verification.

```bash
# ⬇️ Install AWS CLI
sudo apt install awscli -y

# ✅ Verify installation
aws --version
```

> 🟢 **Sign-off:** Terraform and AWS CLI installed and verified.

---

## 🔑 Task 2: Set Up AWS Credentials Using Environment Variables

![AWS](https://img.shields.io/badge/AWS-232F3E?style=flat-square&logo=amazonaws&logoColor=white)
![Bash](https://img.shields.io/badge/Bash-4EAA25?style=flat-square&logo=gnubash&logoColor=white)
![IAM](https://img.shields.io/badge/AWS%20IAM-DD344C?style=flat-square&logo=amazoniam&logoColor=white)

### 🪪 Subtask 2.1: Create AWS Access Keys

> 💡 **Note:** For this lab, you will need AWS access keys. In a real-world scenario, you would obtain these from your AWS account's IAM service. For educational purposes, this lab shows you how to set them up.

### 🗂️ Subtask 2.2: Configure Environment Variables

```bash
# 📂 Create a directory for our Terraform project
mkdir ~/terraform-provider-lab
cd ~/terraform-provider-lab

# ✍️ Create a script to set environment variables
nano aws-credentials.sh
```

Add the following content to `aws-credentials.sh`:

```bash
#!/bin/bash
# 🔑 AWS Credentials - Replace with your actual credentials
export AWS_ACCESS_KEY_ID="your-access-key-here"
export AWS_SECRET_ACCESS_KEY="your-secret-key-here"
export AWS_DEFAULT_REGION="us-east-1"

echo "AWS credentials have been set as environment variables"
echo "Region: $AWS_DEFAULT_REGION"

# TODO: Replace the placeholder access key and secret key with your own AWS IAM credentials
```

Make the script executable and source it:

```bash
# 🔓 Make the script executable
chmod +x aws-credentials.sh

# 📥 Source the script to set environment variables
source ./aws-credentials.sh

# ✅ Verify environment variables are set
echo "Access Key ID: $AWS_ACCESS_KEY_ID"
echo "Region: $AWS_DEFAULT_REGION"
```

### 🔬 Subtask 2.3: Verify Credentials (Optional)

```bash
# 🧪 Test AWS credentials
aws sts get-caller-identity
```

> 🟢 **Sign-off:** AWS credentials securely exported as environment variables and verified.

---

## ⚙️ Task 3: Configure AWS Provider in Terraform

![Terraform](https://img.shields.io/badge/Terraform-844FBA?style=flat-square&logo=terraform&logoColor=white)
![HCL](https://img.shields.io/badge/HCL-5C4EE5?style=flat-square&logo=terraform&logoColor=white)

### 📝 Subtask 3.1: Create Provider Configuration File

```bash
# 📝 Create provider.tf file
nano provider.tf
```

```hcl
# ⚙️ Configure the AWS Provider
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# ☁️ Configure AWS Provider with region
provider "aws" {
  region = var.aws_region

  # 🔑 Credentials will be automatically picked up from environment variables:
  # AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY
}
```

### 🎛️ Subtask 3.2: Create Variables File

```bash
# 📝 Create variables.tf file
nano variables.tf
```

```hcl
# 🌍 AWS Region Variable
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

# 🪣 S3 Bucket Name Variable
variable "bucket_name" {
  description = "Name of the S3 bucket to create"
  type        = string
  default     = "my-terraform-lab-bucket"
}

# 🏷️ Environment Tag Variable
variable "environment" {
  description = "Environment name for resource tagging"
  type        = string
  default     = "lab"
}
```

### 📋 Subtask 3.3: Create Terraform Values File

```bash
# 📝 Create terraform.tfvars file
nano terraform.tfvars
```

```hcl
# 🌍 AWS Configuration
aws_region = "us-east-1"

# 🪣 S3 Bucket Configuration
bucket_name = "terraform-lab-bucket-12345"  # ✏️ Change this to a unique name

# 🏷️ Environment
environment = "development"

# TODO: Replace bucket_name with a globally unique name before applying
```

> 🟢 **Sign-off:** AWS provider wired up to region and credential variables.

---

## 🪣 Task 4: Create S3 Bucket Configuration

![S3](https://img.shields.io/badge/Amazon%20S3-569A31?style=flat-square&logo=amazons3&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-844FBA?style=flat-square&logo=terraform&logoColor=white)
![Security](https://img.shields.io/badge/Security-Hardened-critical?style=flat-square)

### 🏗️ Subtask 4.1: Create Main Configuration File

```bash
# 📝 Create main.tf file
nano main.tf
```

```hcl
# 🪣 Create an S3 bucket
resource "aws_s3_bucket" "lab_bucket" {
  bucket = var.bucket_name

  tags = {
    Name        = var.bucket_name
    Environment = var.environment
    Purpose     = "Terraform Lab"
    CreatedBy   = "Terraform"
  }
}

# 🔁 Configure S3 bucket versioning
resource "aws_s3_bucket_versioning" "lab_bucket_versioning" {
  bucket = aws_s3_bucket.lab_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# 🔐 Configure S3 bucket server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "lab_bucket_encryption" {
  bucket = aws_s3_bucket.lab_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# 🚫 Block public access to the bucket
resource "aws_s3_bucket_public_access_block" "lab_bucket_pab" {
  bucket = aws_s3_bucket.lab_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
```

### 📤 Subtask 4.2: Create Outputs File

```bash
# 📝 Create outputs.tf file
nano outputs.tf
```

```hcl
# 🪣 Output the bucket name
output "bucket_name" {
  description = "Name of the created S3 bucket"
  value       = aws_s3_bucket.lab_bucket.bucket
}

# 🔗 Output the bucket ARN
output "bucket_arn" {
  description = "ARN of the created S3 bucket"
  value       = aws_s3_bucket.lab_bucket.arn
}

# 🌍 Output the bucket region
output "bucket_region" {
  description = "Region where the S3 bucket was created"
  value       = aws_s3_bucket.lab_bucket.region
}

# 🌐 Output the bucket domain name
output "bucket_domain_name" {
  description = "Domain name of the S3 bucket"
  value       = aws_s3_bucket.lab_bucket.bucket_domain_name
}
```

> 🟢 **Sign-off:** S3 bucket resource defined with versioning, encryption, public-access blocking, and outputs.

---

## 🚀 Task 5: Initialize and Deploy Terraform Configuration

![Terraform](https://img.shields.io/badge/Terraform-844FBA?style=flat-square&logo=terraform&logoColor=white)
![CLI](https://img.shields.io/badge/CLI-000000?style=flat-square&logo=gnubash&logoColor=white)

### ⚙️ Subtask 5.1: Initialize Terraform

```bash
# 🔑 Make sure environment variables are still set
source ./aws-credentials.sh

# ⚙️ Initialize Terraform
terraform init
```

> 💡 You should see output indicating that Terraform has been successfully initialized and the AWS provider has been downloaded.

### ✔️ Subtask 5.2: Validate Configuration

```bash
# ✔️ Validate the configuration
terraform validate
```

### 🎨 Subtask 5.3: Format Configuration Files

```bash
# 🎨 Format all .tf files
terraform fmt
```

### 🗺️ Subtask 5.4: Plan the Deployment

```bash
# 🗺️ Create and review the execution plan
terraform plan
```

Terraform should plan to create:

- 1️⃣ S3 bucket
- 1️⃣ S3 bucket versioning configuration
- 1️⃣ S3 bucket encryption configuration
- 1️⃣ S3 bucket public access block

### 🚀 Subtask 5.5: Apply the Configuration

```bash
# 🚀 Apply the configuration
terraform apply
# type "yes" when prompted to confirm
```

### 🔬 Subtask 5.6: Verify the Deployment

```bash
# 🔬 Show the current state
terraform show

# 🗂️ List all resources in the state
terraform state list

# 📤 Get specific output values
terraform output
```

> 🟢 **Sign-off:** S3 bucket, versioning, encryption, and public-access controls deployed and verified.

---

## 🧹 Task 6: Manage and Clean Up Resources

![Terraform](https://img.shields.io/badge/Terraform-844FBA?style=flat-square&logo=terraform&logoColor=white)
![S3](https://img.shields.io/badge/Amazon%20S3-569A31?style=flat-square&logo=amazons3&logoColor=white)

### 🔍 Subtask 6.1: Inspect Created Resources

```bash
# 🔍 Show detailed information about the bucket
terraform state show aws_s3_bucket.lab_bucket

# 📤 Show all outputs
terraform output
```

### ✏️ Subtask 6.2: Make a Configuration Change

```bash
# ✍️ Edit main.tf to add another tag
nano main.tf
```

Modify the `tags` section in the `aws_s3_bucket` resource:

```hcl
  tags = {
    Name        = var.bucket_name
    Environment = var.environment
    Purpose     = "Terraform Lab"
    CreatedBy   = "Terraform"
    LastModified = "2024"  # ✏️ Add this line
  }
```

Apply the change:

```bash
# 🗺️ Plan the change
terraform plan

# 🚀 Apply the change
terraform apply
```

### 🧹 Subtask 6.3: Clean Up Resources

> ⚠️ When you're done with the lab, clean up the resources to avoid charges.

```bash
# 🧹 Destroy all resources
terraform destroy
# type "yes" when prompted to confirm
```

```bash
# ✅ Verify that resources have been destroyed
terraform show
```

> 🟢 **Sign-off:** Configuration change applied, verified, and all resources cleanly destroyed.

---

## 🛠️ Troubleshooting Tips

<details>
<summary>❌ Issue 1: Authentication Errors</summary>

```bash
# If you get authentication errors, verify your environment variables
echo $AWS_ACCESS_KEY_ID
echo $AWS_SECRET_ACCESS_KEY

# Re-source your credentials if needed
source ./aws-credentials.sh
```
</details>

<details>
<summary>❌ Issue 2: Bucket Name Already Exists</summary>

```bash
# S3 bucket names must be globally unique
# Edit terraform.tfvars and change the bucket_name to something unique
nano terraform.tfvars
```
</details>

<details>
<summary>❌ Issue 3: Permission Denied Errors</summary>

Ensure your AWS credentials have the necessary permissions:

- `s3:CreateBucket`
- `s3:DeleteBucket`
- `s3:GetBucketVersioning`
- `s3:PutBucketVersioning`
- `s3:GetBucketEncryption`
- `s3:PutBucketEncryption`
</details>

<details>
<summary>❌ Issue 4: Terraform State Issues</summary>

```bash
# If you encounter state issues, you can refresh the state
terraform refresh

# Or reinitialize if necessary
rm -rf .terraform
terraform init
```
</details>

---

## 🧠 Key Concepts Learned

### 🔌 Provider Configuration

| Concept | Description |
|---|---|
| Provider Block | Defines which cloud provider to use and its configuration |
| Required Providers | Specifies provider source and version constraints |
| Authentication | Using environment variables for secure credential management |

### 🔁 Terraform Workflow

| Command | Purpose |
|---|---|
| `terraform init` | Downloads providers and initializes the working directory |
| `terraform validate` | Checks configuration syntax |
| `terraform plan` | Shows what changes will be made |
| `terraform apply` | Executes the planned changes |
| `terraform destroy` | Removes all managed resources |

### 🏆 Best Practices Demonstrated

- 🔑 Using environment variables for sensitive data
- 📁 Organizing configuration into multiple files
- 🎛️ Using variables for flexibility
- 🏷️ Implementing proper resource tagging
- 🔐 Following security best practices (encryption, public access blocking)

---

## ✅ Conclusion

In this lab, you successfully configured the AWS provider for Terraform and created a complete infrastructure deployment. You learned how to:

- 🔑 Set up secure authentication using environment variables instead of hardcoding credentials
- 📁 Structure Terraform configurations using multiple files (`provider.tf`, `variables.tf`, `main.tf`, `outputs.tf`)
- 🪣 Create and manage AWS S3 buckets with proper security configurations
- ▶️ Execute the complete Terraform workflow from initialization to deployment and cleanup

### 🌍 Real-World Applications

This foundation is crucial for managing cloud infrastructure as code. The provider configuration skills learned here apply to any cloud provider and form the basis for more complex infrastructure deployments. The security practices demonstrated — particularly using environment variables for credentials — are essential for real-world Terraform usage. Understanding provider configuration is fundamental to Terraform success, as it determines how Terraform communicates with your cloud provider and manages your infrastructure resources. This hands-on experience with the complete Terraform workflow prepares you for managing production infrastructure deployments.

---

<div align="center">

![Al Nafi](https://img.shields.io/badge/Al%20Nafi-Cybersecurity%20Training-blueviolet?style=for-the-badge)

</div>
