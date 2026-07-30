<div align="center">

# 🌍 Introduction to Terraform

### Infrastructure as Code (IaC) with Terraform on AWS

![Terraform](https://img.shields.io/badge/Terraform-844FBA?style=for-the-badge&logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazonaws&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![EC2](https://img.shields.io/badge/Amazon%20EC2-FF9900?style=for-the-badge&logo=amazonec2&logoColor=white)
![HCL](https://img.shields.io/badge/HCL-5C4EE5?style=for-the-badge&logo=terraform&logoColor=white)
![IaC](https://img.shields.io/badge/IaC-000000?style=for-the-badge&logo=iota&logoColor=white)

**Difficulty:** 🟢 Beginner &nbsp;|&nbsp; **Duration:** ⏱️ 60–90 minutes &nbsp;|&nbsp; **Track:** ☁️ Cloud DevOps

</div>

---

## 📑 Table of Contents

- [🎯 Lab Objectives](#-lab-objectives)
- [📋 Prerequisites](#-prerequisites)
- [🖥️ Lab Environment](#️-lab-environment)
- [🚀 Task 1: Install Terraform](#-task-1-install-terraform)
- [📁 Task 2: Initialize a Terraform Working Directory](#-task-2-initialize-a-terraform-working-directory)
- [🏗️ Task 3: Write a Basic Terraform Configuration to Create an AWS EC2 Instance](#️-task-3-write-a-basic-terraform-configuration-to-create-an-aws-ec2-instance)
- [🛠️ Troubleshooting Tips](#️-troubleshooting-tips)
- [🧠 Key Concepts](#-key-concepts)
- [✅ Conclusion](#-conclusion)

---

## 🎯 Lab Objectives

By the end of this lab, you will be able to:

| # | Objective |
|---|-----------|
| 1 | 🧩 Understand the fundamental concepts of Infrastructure as Code (IaC) using Terraform |
| 2 | ⚙️ Install and configure Terraform on a Linux system |
| 3 | 📂 Initialize a Terraform working directory and understand the project structure |
| 4 | ✍️ Write basic Terraform configuration files using HashiCorp Configuration Language (HCL) |
| 5 | 🖧 Create and manage AWS EC2 instances using Terraform |
| 6 | ▶️ Execute Terraform commands to plan, apply, and destroy infrastructure |
| 7 | 🗂️ Understand Terraform state management basics |

---

## 📋 Prerequisites

| Requirement | Details |
|---|---|
| 🐧 Linux CLI | Basic understanding of Linux command line operations |
| 📝 Text Editors | Familiarity with `nano`, `vim`, or similar |
| ☁️ Cloud Concepts | Basic knowledge of cloud computing concepts |
| 🔑 AWS Account | Programmatic access (Access Key ID and Secret Access Key) |
| 🌐 Networking | Understanding of VPC, subnets, and security groups |

---

## 🖥️ Lab Environment

> 💡 **Note:** Al Nafi provides Linux-based cloud machines for this lab. Simply click **Start Lab** to access your dedicated Linux machine. The machine is bare metal with no pre-installed tools — you will install Terraform and all required tools during the lab.

![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?style=flat-square&logo=ubuntu&logoColor=white)
![Bash](https://img.shields.io/badge/Bash-4EAA25?style=flat-square&logo=gnubash&logoColor=white)

---

## 🚀 Task 1: Install Terraform

![Terraform](https://img.shields.io/badge/Terraform-844FBA?style=flat-square&logo=terraform&logoColor=white)
![AWS%20CLI](https://img.shields.io/badge/AWS%20CLI-232F3E?style=flat-square&logo=amazonaws&logoColor=white)
![APT](https://img.shields.io/badge/APT-A81D33?style=flat-square&logo=debian&logoColor=white)

### 🔄 Subtask 1.1: Update System Packages

```bash
sudo apt update        # 🔄 refresh package index
sudo apt upgrade -y    # ⬆️ upgrade installed packages
```

### 📦 Subtask 1.2: Install Required Dependencies

```bash
sudo apt install -y wget curl unzip gnupg software-properties-common  # 📦 install download/verify tools
```

### 🔐 Subtask 1.3: Add HashiCorp GPG Key

```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
# 🔐 verifies package authenticity via HashiCorp's official signing key
```

### 📡 Subtask 1.4: Add HashiCorp Repository

```bash
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
# 📡 registers the official HashiCorp APT repository
```

### ⬇️ Subtask 1.5: Install Terraform

```bash
sudo apt update            # 🔄 pick up new repo
sudo apt install terraform # ⬇️ install Terraform CLI
```

### ✅ Subtask 1.6: Verify Terraform Installation

```bash
terraform version   # ✅ confirm successful install
```

Expected output:

```
Terraform v1.6.0
on linux_amd64
```

### 🔑 Subtask 1.7: Install AWS CLI (Required for AWS Authentication)

```bash
sudo apt install -y awscli   # 🔑 install AWS CLI
aws --version                # ✅ verify installation
```

> 🟢 **Sign-off:** Terraform + AWS CLI installed and verified.

---

## 📁 Task 2: Initialize a Terraform Working Directory

![Terraform](https://img.shields.io/badge/Terraform-844FBA?style=flat-square&logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-232F3E?style=flat-square&logo=amazonaws&logoColor=white)
![CLI](https://img.shields.io/badge/CLI-000000?style=flat-square&logo=gnubash&logoColor=white)

### 📂 Subtask 2.1: Create Project Directory

```bash
mkdir ~/terraform-lab   # 📂 project home
cd ~/terraform-lab      # 📍 move into it
```

### 🔑 Subtask 2.2: Configure AWS Credentials

```bash
aws configure   # 🔑 launches interactive credential setup
```

When prompted, enter:

| Field | Value |
|---|---|
| AWS Access Key ID | `<your-access-key>` |
| AWS Secret Access Key | `<your-secret-key>` |
| Default region name | `us-east-1` |
| Default output format | `json` |

```bash
# TODO: Replace with your own AWS Access Key ID and Secret Access Key when prompted
```

### 🗄️ Subtask 2.3: Create Basic Directory Structure

```bash
mkdir -p {modules,environments/dev,environments/prod}   # 🗄️ organized project layout
ls -la                                                   # 👀 confirm structure
```

### ⚙️ Subtask 2.4: Initialize Terraform Working Directory

```bash
terraform init   # ⚙️ downloads provider plugins, sets up .terraform/
```

Expected output:

```
Terraform has been successfully initialized!
```

> 💡 **Note:** At this point, Terraform creates a `.terraform` directory and downloads necessary provider plugins.

### 🔍 Subtask 2.5: Examine Terraform Directory Structure

```bash
ls -la              # 🔍 project root
ls -la .terraform/  # 🔍 provider plugin cache
```

> 🟢 **Sign-off:** Working directory initialized and AWS credentials configured.

---

## 🏗️ Task 3: Write a Basic Terraform Configuration to Create an AWS EC2 Instance

![Terraform](https://img.shields.io/badge/Terraform-844FBA?style=flat-square&logo=terraform&logoColor=white)
![EC2](https://img.shields.io/badge/Amazon%20EC2-FF9900?style=flat-square&logo=amazonec2&logoColor=white)
![VPC](https://img.shields.io/badge/Amazon%20VPC-8C4FFF?style=flat-square&logo=amazonaws&logoColor=white)
![HCL](https://img.shields.io/badge/HCL-5C4EE5?style=flat-square&logo=terraform&logoColor=white)

### ⚙️ Subtask 3.1: Create Provider Configuration

```bash
nano main.tf   # ✍️ open editor
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

# ☁️ Configure AWS Provider
provider "aws" {
  region = var.aws_region
}
```

Save and exit (`Ctrl+X`, then `Y`, then `Enter`).

### 🎛️ Subtask 3.2: Create Variables File

```bash
nano variables.tf
```

```hcl
# 🎛️ Variables for AWS configuration
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "AWS Key Pair name for EC2 access"
  type        = string
  default     = "my-terraform-key"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

# TODO: Adjust instance_type, key_name, and environment for your own use case
```

### 🔎 Subtask 3.3: Create Data Sources

```bash
nano data.tf
```

```hcl
# 🔎 Get the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# 🌐 Get default VPC
data "aws_vpc" "default" {
  default = true
}

# 🧩 Get default subnet
data "aws_subnet" "default" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = "${var.aws_region}a"
  default_for_az    = true
}
```

### 🛡️ Subtask 3.4: Create Security Group Resource

```bash
nano security.tf
```

```hcl
# 🛡️ Create security group for EC2 instance
resource "aws_security_group" "terraform_sg" {
  name_prefix = "terraform-lab-sg-"
  description = "Security group for Terraform lab EC2 instance"
  vpc_id      = data.aws_vpc.default.id

  # 🔓 Allow SSH access
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 🌐 Allow HTTP access
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 🔁 Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "terraform-lab-sg"
    Environment = var.environment
    CreatedBy   = "Terraform"
  }
}

# TODO: Restrict the SSH ingress cidr_blocks to your own IP range before using outside the lab
```

### 🖧 Subtask 3.5: Create EC2 Instance Resource

```bash
nano ec2.tf
```

```hcl
# 🖧 Create EC2 instance
resource "aws_instance" "terraform_instance" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnet.default.id
  vpc_security_group_ids = [aws_security_group.terraform_sg.id]

  # 📜 User data script to install and start Apache
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from Terraform Lab!</h1>" > /var/www/html/index.html
              echo "<p>Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</p>" >> /var/www/html/index.html
              echo "<p>Availability Zone: $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)</p>" >> /var/www/html/index.html
              EOF

  tags = {
    Name        = "terraform-lab-instance"
    Environment = var.environment
    CreatedBy   = "Terraform"
  }
}
```

### 📤 Subtask 3.6: Create Outputs File

```bash
nano outputs.tf
```

```hcl
# 📤 Output values
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.terraform_instance.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.terraform_instance.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.terraform_instance.public_dns
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.terraform_sg.id
}

output "website_url" {
  description = "URL to access the web server"
  value       = "http://${aws_instance.terraform_instance.public_ip}"
}
```

### ✔️ Subtask 3.7: Validate Terraform Configuration

```bash
terraform validate   # ✔️ syntax + internal consistency check
```

Expected output:

```
Success! The configuration is valid.
```

### 🎨 Subtask 3.8: Format Terraform Files

```bash
terraform fmt   # 🎨 auto-format .tf files for consistency
```

### 🔄 Subtask 3.9: Initialize with New Providers

```bash
terraform init   # 🔄 re-init after adding the AWS provider
```

### 🗺️ Subtask 3.10: Plan the Infrastructure

```bash
terraform plan   # 🗺️ preview what will be created
```

Terraform should plan to create:

- 1️⃣ security group
- 1️⃣ EC2 instance

### 🚀 Subtask 3.11: Apply the Configuration

```bash
terraform apply   # 🚀 provision the infrastructure
# type "yes" when prompted to confirm
```

### 🔬 Subtask 3.12: Verify the Deployment

```bash
terraform output                                          # 📋 show all outputs
curl http://$(terraform output -raw instance_public_ip)   # 🌐 test the web server
terraform state list                                       # 🗂️ list managed resources
terraform show                                              # 🔬 detailed resource info
```

### 🗂️ Subtask 3.13: Examine Terraform State

```bash
ls -la terraform.tfstate*        # 🗂️ list state files
cat terraform.tfstate | head -20 # 👀 (optional) inspect state content
```

### ✏️ Subtask 3.14: Make a Configuration Change

```bash
nano ec2.tf
```

```hcl
tags = {
  Name        = "terraform-lab-instance"
  Environment = var.environment
  CreatedBy   = "Terraform"
  Modified    = "true"   # ✏️ new tag demonstrating change management
}
```

```bash
terraform plan    # 🗺️ preview the change
terraform apply   # 🚀 apply the change
```

### 🧹 Subtask 3.15: Clean Up Resources

```bash
terraform destroy   # 🧹 tear down all managed resources
# type "yes" when prompted to confirm

terraform show      # ✅ confirm everything is destroyed
```

> 🟢 **Sign-off:** EC2 instance and security group deployed, validated, modified, and cleanly destroyed via Terraform.

---

## 🛠️ Troubleshooting Tips

<details>
<summary>❌ Issue 1: AWS credentials not configured</summary>

**Solution:** Run `aws configure` and ensure valid credentials are provided.
</details>

<details>
<summary>❌ Issue 2: Terraform initialization fails</summary>

**Solution:** Check internet connectivity and run `terraform init -upgrade`.
</details>

<details>
<summary>❌ Issue 3: EC2 instance creation fails due to key pair</summary>

**Solution:** Either create a key pair in the AWS console or remove the `key_name` reference from the configuration.
</details>

<details>
<summary>❌ Issue 4: Security group rules too permissive</summary>

**Solution:** Modify CIDR blocks to restrict access to specific IP ranges instead of `0.0.0.0/0`.
</details>

<details>
<summary>❌ Issue 5: Instance not accessible via HTTP</summary>

**Solution:** Wait a few minutes for the user data script to complete, or check security group rules.
</details>

---

## 🧠 Key Concepts

| Concept | Description |
|---|---|
| 🧩 Infrastructure as Code (IaC) | Define infrastructure using code, making it version-controlled, repeatable, and consistent |
| 🔁 Terraform Workflow | **Write** → author infrastructure as code, **Plan** → preview changes, **Apply** → provision infrastructure |
| 🗂️ Terraform State | A state file tracks the current state of your infrastructure so Terraform can determine what changes are needed |
| 🔗 Resource Dependencies | Terraform automatically determines the correct order to create resources based on their dependencies |

---

## ✅ Conclusion

In this lab, you have successfully:

- 📥 Installed Terraform on a Linux system using the official HashiCorp repository
- 📂 Initialized a Terraform working directory and understood the project structure
- 🧱 Created a comprehensive Terraform configuration using multiple files for better organization
- 🖧 Deployed an AWS EC2 instance with a security group using Infrastructure as Code principles
- ⌨️ Learned to use Terraform commands including `init`, `validate`, `plan`, `apply`, and `destroy`
- 🗂️ Understood basic Terraform state management and resource dependencies
- 🏆 Implemented best practices such as using variables, data sources, and outputs

### 🌍 Real-World Applications

This foundation in Terraform scales from simple single-resource deployments to complex multi-tier applications across multiple cloud providers. Infrastructure as Code brings the same benefits of version control, testing, and automation that developers enjoy with application code to infrastructure management — a core discipline in modern DevOps practice. The modular approach learned here — separate files for variables, data sources, security groups, and outputs — will serve you well as you progress to more complex Terraform projects involving multiple environments, modules, and team collaboration.

---

<div align="center">

![Al Nafi](https://img.shields.io/badge/Al%20Nafi-Cybersecurity%20Training-blueviolet?style=for-the-badge)

</div>
