<div align="center">

# ☁️ Terraform Cloud Integration

### Remote State, Remote Execution, and Team Collaboration with Terraform Cloud

![Terraform](https://img.shields.io/badge/Terraform-844FBA?style=for-the-badge&logo=terraform&logoColor=white)
![Terraform Cloud](https://img.shields.io/badge/Terraform%20Cloud-5C4EE5?style=for-the-badge&logo=terraform&logoColor=white)
![Git](https://img.shields.io/badge/Git-F05032?style=for-the-badge&logo=git&logoColor=white)
![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white)
![Bash](https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Collaboration](https://img.shields.io/badge/Team%20Collaboration-000000?style=for-the-badge&logo=shieldsdotio&logoColor=white)

</div>

---

## 📋 Table of Contents

- [🎯 Lab Objectives](#-lab-objectives)
- [📌 Prerequisites](#-prerequisites)
- [🖥️ Lab Environment](#️-lab-environment)
- [🧰 Task 1: Environment Setup and Tool Installation](#-task-1-environment-setup-and-tool-installation)
- [☁️ Task 2: Set up Terraform Cloud Workspace](#️-task-2-set-up-terraform-cloud-workspace)
- [🚀 Task 3: Push Configurations to Terraform Cloud](#-task-3-push-configurations-to-terraform-cloud)
- [▶️ Task 4: Use Remote Plans and Applies from Terraform Cloud](#️-task-4-use-remote-plans-and-applies-from-terraform-cloud)
- [🧪 Task 5: Advanced Terraform Cloud Features](#-task-5-advanced-terraform-cloud-features)
- [🤝 Task 6: Workspace Management and Collaboration](#-task-6-workspace-management-and-collaboration)
- [🧹 Task 7: Cleanup and Resource Management](#-task-7-cleanup-and-resource-management)
- [🛠️ Troubleshooting Common Issues](#️-troubleshooting-common-issues)
- [🧠 Key Concepts Learned](#-key-concepts-learned)
- [🏁 Conclusion](#-conclusion)

---

## 🎯 Lab Objectives

By the end of this lab, you will be able to:

| # | Objective |
|---|-----------|
| 1 | ☁️ Set up and configure a **Terraform Cloud** workspace |
| 2 | 🔗 Connect your local Terraform configuration to Terraform Cloud |
| 3 | 🚀 Push Terraform configurations to Terraform Cloud |
| 4 | ▶️ Execute remote plans and applies using Terraform Cloud |
| 5 | 🗃️ Understand the benefits of remote state management and collaboration |
| 6 | 🔗 Configure version control integration with Terraform Cloud |

---

## 📌 Prerequisites

| Requirement | Details |
|-------------|---------|
| 🌍 Terraform Basics | Basic understanding of Terraform concepts (resources, providers, state) |
| 💻 Linux CLI | Familiarity with Linux command line operations |
| 🌿 Git | Basic knowledge of Git version control |
| 🏗️ IaC Principles | Understanding of Infrastructure as Code (IaC) principles |
| 🐙 GitHub Account | A GitHub account (free tier is sufficient) |
| ☁️ Terraform Cloud Account | A Terraform Cloud account (free tier is sufficient) |

---

## 🖥️ Lab Environment

> 💡 Al Nafi provides Linux-based cloud machines for this lab. Simply click **Start Lab** to access your dedicated Linux machine. The provided machine is **bare metal with no pre-installed tools** — you will install all required tools during the lab exercises.

---

## 🧰 Task 1: Environment Setup and Tool Installation

### 📦 Subtask 1.1: Install Required Tools

**1️⃣ Update your system and install the necessary tools:**
```bash
# ⬆️ Update system packages
sudo apt update && sudo apt upgrade -y

# 📥 Install curl and wget
sudo apt install -y curl wget unzip git

# 🌍 Install Terraform
wget https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_linux_amd64.zip
unzip terraform_1.6.6_linux_amd64.zip
sudo mv terraform /usr/local/bin/
rm terraform_1.6.6_linux_amd64.zip

# 🔍 Verify Terraform installation
terraform version
```

### 🌿 Subtask 1.2: Install and Configure Git

```bash
# 🧑‍💻 Configure Git with your information
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# 🔍 Verify Git configuration
git config --list
```

### 📁 Subtask 1.3: Create Project Directory Structure

```bash
# 📂 Create main project directory
mkdir -p ~/terraform-cloud-lab
cd ~/terraform-cloud-lab

# 🗂️ Create subdirectories for organization
mkdir -p {configurations,scripts,docs}

# 🌱 Initialize as Git repository
git init
```

> 🎓 **TODO:** Before Task 2, decide on your Terraform Cloud organization name — you'll need it in both `main.tf` (Subtask 2.4) and the workspace UI, so picking it now avoids a mismatch later.

---

## ☁️ Task 2: Set up Terraform Cloud Workspace

### 🆕 Subtask 2.1: Create Terraform Cloud Account and Organization

1. 🌐 Open a web browser and navigate to https://app.terraform.io
2. ✍️ Sign up for a free Terraform Cloud account if you don't have one
3. 🏢 Create a new organization or use an existing one
4. 📝 Note down your organization name for later use

### 🔑 Subtask 2.2: Generate Terraform Cloud API Token

1. 👤 In Terraform Cloud, click on your profile picture in the top right
2. ⚙️ Select **User Settings**
3. 🔐 Click on **Tokens** in the left sidebar
4. ➕ Click **Create an API token**
5. 📝 Enter a description like `"Lab 18 Token"`
6. 📋 Copy the generated token and save it securely

### 🔐 Subtask 2.3: Configure Terraform CLI Authentication

```bash
# 📂 Create Terraform CLI configuration directory
mkdir -p ~/.terraform.d

# 🔑 Create credentials file
cat > ~/.terraform.d/credentials.tfrc.json << 'EOF'
{
  "credentials": {
    "app.terraform.io": {
      "token": "YOUR_TERRAFORM_CLOUD_TOKEN_HERE"
    }
  }
}
EOF

# ✏️ Replace YOUR_TERRAFORM_CLOUD_TOKEN_HERE with your actual token
# Use a text editor to update the token
nano ~/.terraform.d/credentials.tfrc.json
```

### 📝 Subtask 2.4: Create Initial Terraform Configuration

```bash
# 📂 Navigate to configurations directory
cd ~/terraform-cloud-lab/configurations

# 📝 Create main Terraform configuration file
cat > main.tf << 'EOF'
terraform {
  required_version = ">= 1.0"

  cloud {
    organization = "YOUR_ORG_NAME"

    workspaces {
      name = "terraform-cloud-lab"
    }
  }

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4"
    }
  }
}

# 🎲 Random string resource
resource "random_string" "lab_id" {
  length  = 8
  special = false
  upper   = false
}

# 📄 Local file resource
resource "local_file" "lab_output" {
  filename = "${path.module}/lab-output-${random_string.lab_id.result}.txt"
  content  = <<-EOT
    Terraform Cloud Lab Output
    ==========================
    Lab ID: ${random_string.lab_id.result}
    Timestamp: ${timestamp()}
    Workspace: terraform-cloud-lab
    Organization: YOUR_ORG_NAME

    This file was created using Terraform Cloud remote execution!
  EOT
}

# 📤 Output values
output "lab_id" {
  description = "Unique identifier for this lab run"
  value       = random_string.lab_id.result
}

output "output_file" {
  description = "Path to the generated output file"
  value       = local_file.lab_output.filename
}
EOF

# ✏️ Replace YOUR_ORG_NAME with your actual Terraform Cloud organization name
nano main.tf
```

### 🧩 Subtask 2.5: Create Variables Configuration

```bash
# 📝 Create variables file
cat > variables.tf << 'EOF'
variable "environment" {
  description = "Environment name for the lab"
  type        = string
  default     = "development"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "terraform-cloud-lab"
}

variable "tags" {
  description = "Common tags for resources"
  type        = map(string)
  default = {
    Environment = "development"
    Project     = "terraform-cloud-lab"
    ManagedBy   = "terraform-cloud"
  }
}
EOF
```

---

## 🚀 Task 3: Push Configurations to Terraform Cloud

### ⚙️ Subtask 3.1: Initialize Terraform with Cloud Backend

```bash
# 🚀 Initialize Terraform (this will prompt for workspace creation)
terraform init
```

> ℹ️ When prompted, select **yes** to create the new workspace in Terraform Cloud.

### 🐙 Subtask 3.2: Create GitHub Repository (Optional but Recommended)

```bash
# ➕ Add all files to Git
git add .

# 💾 Create initial commit
git commit -m "Initial Terraform Cloud configuration"

# 🧾 Create .gitignore file
cat > .gitignore << 'EOF'
# Terraform files
*.tfstate
*.tfstate.*
.terraform/
.terraform.lock.hcl
terraform.tfvars
*.tfvars

# OS files
.DS_Store
Thumbs.db

# IDE files
.vscode/
.idea/
*.swp
*.swo
EOF

# ➕ Add and commit .gitignore
git add .gitignore
git commit -m "Add .gitignore file"
```

### ⚙️ Subtask 3.3: Configure Workspace Settings in Terraform Cloud

1. 🌐 Navigate to your Terraform Cloud workspace in the web browser
2. ⚙️ Go to **Settings > General**
3. 🖥️ Set the **Execution Mode** to `Remote`
4. ✋ Set the **Apply Method** to `Manual apply` for learning purposes
5. 💾 Save the settings

### 🧩 Subtask 3.4: Set Workspace Variables

1. 🌐 In your workspace, go to **Variables**
2. ➕ Add the following Terraform variables:
   - `environment`: `development`
   - `project_name`: `terraform-cloud-lab`
3. 🔧 Add any environment variables if needed
4. 💾 Save the variables

---

## ▶️ Task 4: Use Remote Plans and Applies from Terraform Cloud

### 📖 Subtask 4.1: Execute Remote Plan

```bash
# 📖 Run terraform plan (this will execute remotely)
terraform plan
```

> ℹ️ Observe how the plan execution happens in **Terraform Cloud** rather than locally.

### 👀 Subtask 4.2: Monitor Plan in Terraform Cloud UI

1. 🌐 Open your workspace in Terraform Cloud
2. 🏃 Navigate to **Runs**
3. 🔍 Click on the latest run to see detailed logs
4. 📋 Review the plan output and proposed changes

### ✅ Subtask 4.3: Execute Remote Apply

```bash
# ✅ Run terraform apply (this will execute remotely)
terraform apply
```

> ℹ️ When prompted, type **yes** to confirm the apply operation.

### 🗃️ Subtask 4.4: Verify Remote State Management

```bash
# 🗃️ Try to view state (note: state is stored remotely)
terraform show

# 📋 List resources in state
terraform state list

# 🔍 View specific resource
terraform state show random_string.lab_id
```

### 📄 Subtask 4.5: Check Generated Files

```bash
# 👀 List files in current directory
ls -la

# 📄 View the generated output file
cat lab-output-*.txt
```

---

## 🧪 Task 5: Advanced Terraform Cloud Features

### 🔧 Subtask 5.1: Create Additional Configuration

```bash
# 🔧 Create a more complex configuration
cat > advanced.tf << 'EOF'
# 🎲 Additional random resources
resource "random_password" "lab_password" {
  length  = 16
  special = true
}

resource "random_uuid" "lab_uuid" {}

# 📄 Local file with more complex content
resource "local_file" "advanced_output" {
  filename = "${path.module}/advanced-${random_string.lab_id.result}.json"
  content = jsonencode({
    lab_info = {
      id          = random_string.lab_id.result
      uuid        = random_uuid.lab_uuid.result
      environment = var.environment
      project     = var.project_name
      timestamp   = timestamp()
      tags        = var.tags
    }
    security = {
      password_length = length(random_password.lab_password.result)
      has_special     = random_password.lab_password.special
    }
  })
}

# 📤 Additional outputs
output "lab_uuid" {
  description = "UUID for this lab session"
  value       = random_uuid.lab_uuid.result
}

output "advanced_file" {
  description = "Path to the advanced JSON output file"
  value       = local_file.advanced_output.filename
}
EOF
```

### ▶️ Subtask 5.2: Plan and Apply Changes

```bash
# 📖 Plan the changes
terraform plan

# ✅ Apply the changes
terraform apply
```

### 📤 Subtask 5.3: View Updated Outputs

```bash
# 📋 View all outputs
terraform output

# 🔍 View specific output
terraform output lab_id
terraform output lab_uuid

# 📄 Check the generated JSON file
cat advanced-*.json | python3 -m json.tool
```

---

## 🤝 Task 6: Workspace Management and Collaboration

### 📝 Subtask 6.1: Create Terraform Variables File

```bash
# 📝 Create terraform.tfvars.example file
cat > terraform.tfvars.example << 'EOF'
# Example variables file for Terraform Cloud Lab
environment  = "development"
project_name = "terraform-cloud-lab"

tags = {
  Environment = "development"
  Project     = "terraform-cloud-lab"
  ManagedBy   = "terraform-cloud"
  Owner       = "lab-student"
}
EOF
```

### 🔄 Subtask 6.2: Test Workspace Variables Override

1. 🌐 In Terraform Cloud workspace, go to **Variables**
2. ✏️ Update the `environment` variable to `production`
3. 📖 Run a new plan to see how workspace variables override defaults

```bash
# 📖 Run plan to see variable changes
terraform plan
```

### 🏃 Subtask 6.3: View Run History

1. 🌐 In Terraform Cloud, navigate to **Runs**
2. 📋 Review the history of all runs
3. 🔍 Click on different runs to compare changes
4. 📊 Notice how each run is tracked and auditable

---

## 🧹 Task 7: Cleanup and Resource Management

### 🗑️ Subtask 7.1: Destroy Resources

```bash
# 📖 Plan destroy operation
terraform plan -destroy

# 🗑️ Execute destroy
terraform destroy
```

### ✅ Subtask 7.2: Verify Cleanup

```bash
# 👀 Check that local files are removed
ls -la *.txt *.json

# 🗃️ Verify state is empty
terraform show
```

### 💾 Subtask 7.3: Final Git Commit

```bash
# ➕ Add all changes to Git
git add .

# 💾 Commit final state
git commit -m "Complete Terraform Cloud integration lab"

# 📜 View Git log
git log --oneline
```

---

## 🛠️ Troubleshooting Common Issues

<details>
<summary>❗ Issue 1: Authentication Problems</summary>

If you encounter authentication issues:
```bash
# 🔍 Verify credentials file
cat ~/.terraform.d/credentials.tfrc.json

# 🔐 Test authentication
terraform login
```
</details>

<details>
<summary>❗ Issue 2: Workspace Not Found</summary>

If Terraform cannot find your workspace:
- ✅ Verify organization name in `main.tf`
- ✅ Check workspace name spelling
- ✅ Ensure workspace exists in Terraform Cloud
</details>

<details>
<summary>❗ Issue 3: Remote Execution Failures</summary>

If remote execution fails:
- ✅ Check workspace execution mode is set to `Remote`
- ✅ Verify all required variables are set in the workspace
- ✅ Review run logs in Terraform Cloud UI
</details>

<details>
<summary>❗ Issue 4: State Lock Issues</summary>

If you encounter state lock issues:
```bash
# ⚠️ Force unlock (use with caution)
terraform force-unlock LOCK_ID
```
</details>

---

## 🧠 Key Concepts Learned

### 🗃️ Remote State Management

Terraform Cloud automatically manages your state file remotely, providing:
- 🔒 **State locking** to prevent concurrent modifications
- 🕰️ **State versioning** for rollback capabilities
- 🔐 **Secure storage** with encryption at rest and in transit

### ▶️ Remote Execution

All Terraform operations run in Terraform Cloud's infrastructure:
- 🖥️ Consistent environment across team members
- 📜 Audit logging of all operations
- 🛡️ Policy enforcement capabilities

### 🧩 Workspace Variables

Variables can be set at the workspace level:
- ⚙️ Terraform variables for configuration
- 🔧 Environment variables for provider authentication
- 🔐 Sensitive variables are encrypted and hidden

### 🤝 Collaboration Features

Terraform Cloud enables team collaboration:
- ✅ Run approval workflows
- 💬 Comment and discussion on runs
- 🔑 Role-based access control

---

## 🏁 Conclusion

In this lab, you successfully integrated Terraform with Terraform Cloud, experiencing the benefits of remote state management and execution. You learned how to:

- ☁️ Set up and configure a Terraform Cloud workspace
- 🔐 Authenticate your local Terraform CLI with Terraform Cloud
- 🚀 Push configurations and execute remote plans and applies
- 🧩 Manage workspace variables and settings
- 👀 Monitor and audit Terraform operations through the web interface

This integration is crucial for production environments and team collaboration, as it provides centralized state management, consistent execution environments, and comprehensive audit trails. Terraform Cloud's remote execution ensures that all team members work with the same Terraform version and provider configurations, reducing the "works on my machine" problem common in infrastructure management.

### 🌍 Real-World Applications

The skills you've developed in this lab form the foundation for implementing Infrastructure as Code in enterprise environments, where collaboration, security, and auditability are essential requirements.

---

<div align="center">

![Al Nafi](https://img.shields.io/badge/Al%20Nafi-Cybersecurity%20Training-blueviolet?style=for-the-badge)

</div>
