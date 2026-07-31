<div align="center">

# 🔄 Integrating Terraform with CI/CD

### Automated Plan, Apply, and Drift Detection Pipelines with GitHub Actions

![Terraform](https://img.shields.io/badge/Terraform-844FBA?style=for-the-badge&logo=terraform&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-2088FF?style=for-the-badge&logo=github-actions&logoColor=white)
![GitHub CLI](https://img.shields.io/badge/GitHub%20CLI-181717?style=for-the-badge&logo=github&logoColor=white)
![Checkov](https://img.shields.io/badge/Checkov-00B4AB?style=for-the-badge&logo=bridgecrew&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![YAML](https://img.shields.io/badge/YAML-CB171E?style=for-the-badge&logo=yaml&logoColor=white)
![Bash](https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)
![DevOps](https://img.shields.io/badge/DevOps-000000?style=for-the-badge&logo=shieldsdotio&logoColor=white)

</div>

---

## 📋 Table of Contents

- [🎯 Lab Objectives](#-lab-objectives)
- [📌 Prerequisites](#-prerequisites)
- [🖥️ Lab Environment](#️-lab-environment)
- [🧰 Task 1: Environment Setup and Tool Installation](#-task-1-environment-setup-and-tool-installation)
- [🏗️ Task 2: Create Terraform Infrastructure Code](#️-task-2-create-terraform-infrastructure-code)
- [⚙️ Task 3: Create GitHub Actions CI/CD Pipeline](#️-task-3-create-github-actions-cicd-pipeline)
- [🚀 Task 4: Initialize Git Repository and Test Locally](#-task-4-initialize-git-repository-and-test-locally)
- [🔁 Task 5: Test CI/CD Pipeline with Infrastructure Changes](#-task-5-test-cicd-pipeline-with-infrastructure-changes)
- [🧪 Task 6: Advanced CI/CD Features and Best Practices](#-task-6-advanced-cicd-features-and-best-practices)
- [✅ Task 7: Testing and Validation](#-task-7-testing-and-validation)
- [🛠️ Troubleshooting Common Issues](#️-troubleshooting-common-issues)
- [🏆 Best Practices Implemented](#-best-practices-implemented)
- [🏁 Conclusion](#-conclusion)

---

## 🎯 Lab Objectives

By the end of this lab, you will be able to:

| # | Objective |
|---|-----------|
| 1 | ⚙️ Set up a complete **CI/CD pipeline** using GitHub Actions for automated Terraform deployments |
| 2 | 🔀 Configure automatic `terraform apply` operations on merge to the main branch |
| 3 | 🔐 Implement proper security practices for CI/CD with Terraform state management |
| 4 | 🧪 Test and validate CI/CD integration with infrastructure changes |
| 5 | 📘 Understand best practices for Infrastructure as Code (IaC) in production environments |

---

## 📌 Prerequisites

| Requirement | Details |
|-------------|---------|
| 🌿 Git & GitHub | Basic understanding of Git and GitHub workflows |
| 🌍 Terraform | Familiarity with Terraform fundamentals (resources, providers, state) |
| 💻 Linux CLI | Knowledge of Linux command line operations |
| 🔄 CI/CD Concepts | Understanding of CI/CD concepts |
| 📄 YAML | Basic knowledge of YAML syntax |

---

## 🖥️ Lab Environment

> 💡 Al Nafi provides Linux-based cloud machines for this lab. Simply click **Start Lab** to access your dedicated Linux machine. The provided machine is **bare metal with no pre-installed tools** — you will install all required tools during the lab exercises.

---

## 🧰 Task 1: Environment Setup and Tool Installation

### 📦 Subtask 1.1: Install Required Tools

**1️⃣ Update your system and install the necessary tools for this lab:**
```bash
# ⬆️ Update system packages
sudo apt update && sudo apt upgrade -y

# 📥 Install curl and wget
sudo apt install -y curl wget unzip git

# 🌍 Install Terraform
wget https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_linux_amd64.zip
unzip terraform_1.6.6_linux_amd64.zip
sudo mv terraform /usr/local/bin/
terraform version

# 🐙 Install GitHub CLI
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh -y

# 🐳 Install Docker (for local testing)
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
newgrp docker
```

### 🔑 Subtask 1.2: Configure Git and GitHub

**1️⃣ Set up your Git configuration and authenticate with GitHub:**
```bash
# 🧑‍💻 Configure Git (replace with your information)
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# 🔐 Authenticate with GitHub CLI
gh auth login
```

> ℹ️ Follow the interactive prompts to authenticate with your GitHub account.

### 📁 Subtask 1.3: Create Project Directory Structure

**1️⃣ Create the directory structure for your Terraform CI/CD project:**
```bash
# 📂 Create project directory
mkdir ~/terraform-cicd-lab
cd ~/terraform-cicd-lab

# 🗂️ Create directory structure
mkdir -p {terraform,scripts,.github/workflows}

# 📝 Create initial files
touch terraform/main.tf
touch terraform/variables.tf
touch terraform/outputs.tf
touch terraform/terraform.tf
touch .gitignore
touch README.md
```

> 🎓 **TODO:** Before Task 2, jot down which of these files you expect `terraform-plan.yml` to watch for changes in — you'll confirm your guess when you write the `paths:` filter in Task 3.

---

## 🏗️ Task 2: Create Terraform Infrastructure Code

### 🔌 Subtask 2.1: Configure Terraform Backend and Provider

**1️⃣ Create the basic Terraform configuration files:**
```hcl
# Create terraform/terraform.tf
cat > terraform/terraform.tf << 'EOF'
terraform {
  required_version = ">= 1.0"

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

  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "local" {}
provider "random" {}
EOF
```

### 🧱 Subtask 2.2: Create Infrastructure Resources

**1️⃣ Create a simple infrastructure configuration for testing:**
```hcl
# Create terraform/variables.tf
cat > terraform/variables.tf << 'EOF'
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "terraform-cicd"
}

variable "file_count" {
  description = "Number of files to create"
  type        = number
  default     = 3
}
EOF
```

```hcl
# Create terraform/main.tf
cat > terraform/main.tf << 'EOF'
# 🎲 Generate random string for unique naming
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# 📄 Create multiple local files
resource "local_file" "demo_files" {
  count = var.file_count

  filename = "${path.module}/generated/demo-${var.environment}-${count.index + 1}-${random_string.suffix.result}.txt"
  content  = <<-EOT
    Environment: ${var.environment}
    Project: ${var.project_name}
    File Number: ${count.index + 1}
    Generated at: ${timestamp()}
    Random Suffix: ${random_string.suffix.result}
  EOT
}

# 📊 Create a summary file
resource "local_file" "summary" {
  filename = "${path.module}/generated/summary-${var.environment}-${random_string.suffix.result}.json"
  content = jsonencode({
    environment   = var.environment
    project_name  = var.project_name
    file_count    = var.file_count
    files_created = local_file.demo_files[*].filename
    timestamp     = timestamp()
    random_suffix = random_string.suffix.result
  })
}
EOF
```

```hcl
# Create terraform/outputs.tf
cat > terraform/outputs.tf << 'EOF'
output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "files_created" {
  description = "List of files created"
  value       = local_file.demo_files[*].filename
}

output "summary_file" {
  description = "Summary file location"
  value       = local_file.summary.filename
}

output "random_suffix" {
  description = "Random suffix used"
  value       = random_string.suffix.result
}
EOF
```

### 🧾 Subtask 2.3: Create Supporting Files

**1️⃣ Create `.gitignore`:**
```bash
cat > .gitignore << 'EOF'
# Terraform files
*.tfstate
*.tfstate.*
*.tfvars
.terraform/
.terraform.lock.hcl
terraform.tfplan

# Generated files
terraform/generated/

# OS files
.DS_Store
Thumbs.db

# IDE files
.vscode/
.idea/
*.swp
*.swo

# Logs
*.log
EOF
```

**2️⃣ Create `README.md`:**
```markdown
cat > README.md << 'EOF'
# Terraform CI/CD Lab

This repository demonstrates integrating Terraform with CI/CD pipelines using GitHub Actions.

## Structure

- `terraform/` - Terraform configuration files
- `.github/workflows/` - GitHub Actions workflow files
- `scripts/` - Helper scripts

## Workflows

- **terraform-plan.yml** - Runs on pull requests to show planned changes
- **terraform-apply.yml** - Runs on main branch to apply changes

## Usage

1. Make changes to Terraform files
2. Create a pull request
3. Review the plan output in the PR
4. Merge to main to apply changes
EOF
```

---

## ⚙️ Task 3: Create GitHub Actions CI/CD Pipeline

### 📖 Subtask 3.1: Create Terraform Plan Workflow

**1️⃣ Create a workflow that runs `terraform plan` on pull requests:**
```yaml
# Create .github/workflows/terraform-plan.yml
cat > .github/workflows/terraform-plan.yml << 'EOF'
name: 'Terraform Plan'

on:
  pull_request:
    branches:
      - main
    paths:
      - 'terraform/**'
      - '.github/workflows/terraform-*.yml'

env:
  TF_VERSION: '1.6.6'
  TF_WORKING_DIR: './terraform'

jobs:
  terraform-plan:
    name: 'Terraform Plan'
    runs-on: ubuntu-latest

    defaults:
      run:
        working-directory: ${{ env.TF_WORKING_DIR }}

    steps:
    - name: 'Checkout'
      uses: actions/checkout@v4

    - name: 'Setup Terraform'
      uses: hashicorp/setup-terraform@v3
      with:
        terraform_version: ${{ env.TF_VERSION }}

    - name: 'Terraform Format Check'
      id: fmt
      run: terraform fmt -check -recursive
      continue-on-error: true

    - name: 'Terraform Init'
      id: init
      run: terraform init

    - name: 'Terraform Validate'
      id: validate
      run: terraform validate -no-color

    - name: 'Terraform Plan'
      id: plan
      run: |
        terraform plan -no-color -out=tfplan
        terraform show -no-color tfplan > plan_output.txt
      continue-on-error: true

    - name: 'Comment PR'
      uses: actions/github-script@v7
      if: github.event_name == 'pull_request'
      env:
        PLAN: "terraform\n${{ steps.plan.outputs.stdout }}"
      with:
        github-token: ${{ secrets.GITHUB_TOKEN }}
        script: |
          const output = `#### Terraform Format and Style 🖌\`${{ steps.fmt.outcome }}\`
          #### Terraform Initialization ⚙️\`${{ steps.init.outcome }}\`
          #### Terraform Validation 🤖\`${{ steps.validate.outcome }}\`
          #### Terraform Plan 📖\`${{ steps.plan.outcome }}\`

          <details><summary>Show Plan</summary>

          \`\`\`terraform
          ${process.env.PLAN}
          \`\`\`

          </details>

          *Pusher: @${{ github.actor }}, Action: \`${{ github.event_name }}\`*`;

          github.rest.issues.createComment({
            issue_number: context.issue.number,
            owner: context.repo.owner,
            repo: context.repo.repo,
            body: output
          })

    - name: 'Terraform Plan Status'
      if: steps.plan.outcome == 'failure'
      run: exit 1
EOF
```

### ✅ Subtask 3.2: Create Terraform Apply Workflow

**1️⃣ Create a workflow that applies changes when merged to main:**
```yaml
# Create .github/workflows/terraform-apply.yml
cat > .github/workflows/terraform-apply.yml << 'EOF'
name: 'Terraform Apply'

on:
  push:
    branches:
      - main
    paths:
      - 'terraform/**'
      - '.github/workflows/terraform-*.yml'

env:
  TF_VERSION: '1.6.6'
  TF_WORKING_DIR: './terraform'

jobs:
  terraform-apply:
    name: 'Terraform Apply'
    runs-on: ubuntu-latest

    defaults:
      run:
        working-directory: ${{ env.TF_WORKING_DIR }}

    steps:
    - name: 'Checkout'
      uses: actions/checkout@v4

    - name: 'Setup Terraform'
      uses: hashicorp/setup-terraform@v3
      with:
        terraform_version: ${{ env.TF_VERSION }}

    - name: 'Terraform Init'
      id: init
      run: terraform init

    - name: 'Terraform Plan'
      id: plan
      run: terraform plan -no-color -out=tfplan

    - name: 'Terraform Apply'
      id: apply
      run: terraform apply -auto-approve tfplan

    - name: 'Upload Generated Files'
      uses: actions/upload-artifact@v4
      if: always()
      with:
        name: terraform-generated-files
        path: ${{ env.TF_WORKING_DIR }}/generated/
        retention-days: 30

    - name: 'Terraform Output'
      id: output
      run: terraform output -json > terraform_outputs.json

    - name: 'Upload Terraform Outputs'
      uses: actions/upload-artifact@v4
      with:
        name: terraform-outputs
        path: ${{ env.TF_WORKING_DIR }}/terraform_outputs.json
        retention-days: 30
EOF
```

### 🛑 Subtask 3.3: Create Terraform Destroy Workflow (Manual)

**1️⃣ Create a manual workflow for destroying infrastructure:**
```yaml
# Create .github/workflows/terraform-destroy.yml
cat > .github/workflows/terraform-destroy.yml << 'EOF'
name: 'Terraform Destroy'

on:
  workflow_dispatch:
    inputs:
      confirm_destroy:
        description: 'Type "destroy" to confirm'
        required: true
        default: ''

env:
  TF_VERSION: '1.6.6'
  TF_WORKING_DIR: './terraform'

jobs:
  terraform-destroy:
    name: 'Terraform Destroy'
    runs-on: ubuntu-latest

    defaults:
      run:
        working-directory: ${{ env.TF_WORKING_DIR }}

    steps:
    - name: 'Validate Confirmation'
      if: github.event.inputs.confirm_destroy != 'destroy'
      run: |
        echo "Confirmation failed. You must type 'destroy' to proceed."
        exit 1

    - name: 'Checkout'
      uses: actions/checkout@v4

    - name: 'Setup Terraform'
      uses: hashicorp/setup-terraform@v3
      with:
        terraform_version: ${{ env.TF_VERSION }}

    - name: 'Terraform Init'
      id: init
      run: terraform init

    - name: 'Terraform Destroy Plan'
      id: destroy_plan
      run: terraform plan -destroy -no-color -out=destroy_plan

    - name: 'Terraform Destroy'
      id: destroy
      run: terraform apply -auto-approve destroy_plan
EOF
```

> 🎓 **TODO:** Notice that `terraform-destroy.yml` requires typing the literal word `destroy` as a `workflow_dispatch` input. Explain in one sentence why this manual confirmation gate matters more here than on the plan/apply workflows.

---

## 🚀 Task 4: Initialize Git Repository and Test Locally

### 🧪 Subtask 4.1: Initialize Repository and Test Terraform

**1️⃣ Initialize the Git repository and test Terraform locally:**
```bash
# 🌱 Initialize Git repository
cd ~/terraform-cicd-lab
git init
git add .
git commit -m "Initial commit: Terraform CI/CD setup"

# 🧪 Test Terraform locally
cd terraform
terraform init
terraform plan
terraform apply -auto-approve

# 👀 Check generated files
ls -la generated/
cat generated/summary-*.json

# 🧹 Clean up for testing
terraform destroy -auto-approve
cd ..
```

### 🐙 Subtask 4.2: Create GitHub Repository

**1️⃣ Create a GitHub repository and push your code:**
```bash
# 🆕 Create GitHub repository
gh repo create terraform-cicd-lab --public --description "Terraform CI/CD Lab with GitHub Actions"

# 🔗 Add remote and push
git remote add origin https://github.com/$(gh api user --jq .login)/terraform-cicd-lab.git
git branch -M main
git push -u origin main
```

---

## 🔁 Task 5: Test CI/CD Pipeline with Infrastructure Changes

### 🌿 Subtask 5.1: Create Feature Branch and Make Changes

**1️⃣ Create a feature branch to test the CI/CD pipeline:**
```bash
# 🌿 Create and switch to feature branch
git checkout -b feature/increase-file-count

# ✏️ Modify variables to increase file count
sed -i 's/default     = 3/default     = 5/' terraform/variables.tf

# ➕ Add a new output
cat >> terraform/outputs.tf << 'EOF'

output "total_resources" {
  description = "Total number of resources created"
  value       = length(local_file.demo_files) + 1
}
EOF

# 💾 Commit changes
git add .
git commit -m "Increase file count from 3 to 5 and add total_resources output"

# ⬆️ Push feature branch
git push -u origin feature/increase-file-count
```

### 🔍 Subtask 5.2: Create Pull Request and Review Plan

**1️⃣ Create a pull request to trigger the plan workflow:**
```bash
# 📬 Create pull request
gh pr create --title "Increase file count and add new output" --body "This PR increases the number of generated files from 3 to 5 and adds a new output for total resources count."
```

> ℹ️ Check the **GitHub Actions** tab in your repository to see the `terraform-plan` workflow running. The workflow will:
> - ✅ Check Terraform formatting
> - ⚙️ Initialize Terraform
> - 🤖 Validate the configuration
> - 📖 Generate a plan
> - 💬 Comment the plan on the pull request

### 🔀 Subtask 5.3: Merge Pull Request and Trigger Apply

**1️⃣ After reviewing the plan, merge the pull request to trigger the apply workflow:**
```bash
# 🔀 Merge the pull request
gh pr merge --merge

# 🔄 Switch back to main and pull changes
git checkout main
git pull origin main
```

> ℹ️ Monitor the **GitHub Actions** tab to see the `terraform-apply` workflow running. This workflow will:
> - ⚙️ Initialize Terraform
> - 📖 Generate a plan
> - ✅ Apply the changes
> - 📦 Upload generated files as artifacts
> - 💾 Save Terraform outputs

### 🔎 Subtask 5.4: Verify Applied Changes

**1️⃣ Check the workflow artifacts and verify the changes were applied:**
```bash
# 📋 List recent workflow runs
gh run list --limit 5

# 🆔 Get the latest apply workflow run ID
APPLY_RUN_ID=$(gh run list --workflow="terraform-apply.yml" --limit 1 --json databaseId --jq '.[0].databaseId')

# ⬇️ Download artifacts
gh run download $APPLY_RUN_ID

# 👀 Check downloaded artifacts
ls -la terraform-generated-files/
cat terraform-outputs/terraform_outputs.json
```

---

## 🧪 Task 6: Advanced CI/CD Features and Best Practices

### 🌎 Subtask 6.1: Add Environment-Specific Deployments

**1️⃣ Create environment-specific workflows for staging and production:**
```yaml
# Create staging workflow
cat > .github/workflows/terraform-staging.yml << 'EOF'
name: 'Deploy to Staging'

on:
  push:
    branches:
      - develop
    paths:
      - 'terraform/**'

env:
  TF_VERSION: '1.6.6'
  TF_WORKING_DIR: './terraform'
  TF_VAR_environment: 'staging'

jobs:
  deploy-staging:
    name: 'Deploy to Staging'
    runs-on: ubuntu-latest
    environment: staging

    defaults:
      run:
        working-directory: ${{ env.TF_WORKING_DIR }}

    steps:
    - name: 'Checkout'
      uses: actions/checkout@v4

    - name: 'Setup Terraform'
      uses: hashicorp/setup-terraform@v3
      with:
        terraform_version: ${{ env.TF_VERSION }}

    - name: 'Terraform Init'
      run: terraform init

    - name: 'Terraform Plan'
      run: terraform plan -var="environment=staging" -out=tfplan

    - name: 'Terraform Apply'
      run: terraform apply -auto-approve tfplan

    - name: 'Upload Staging Artifacts'
      uses: actions/upload-artifact@v4
      with:
        name: staging-generated-files
        path: ${{ env.TF_WORKING_DIR }}/generated/
EOF
```

### 🔒 Subtask 6.2: Add Security Scanning

**1️⃣ Add security scanning to your CI/CD pipeline:**
```yaml
# Create security workflow
cat > .github/workflows/security-scan.yml << 'EOF'
name: 'Security Scan'

on:
  pull_request:
    branches:
      - main
    paths:
      - 'terraform/**'
  push:
    branches:
      - main
    paths:
      - 'terraform/**'

jobs:
  security-scan:
    name: 'Security Scan'
    runs-on: ubuntu-latest

    steps:
    - name: 'Checkout'
      uses: actions/checkout@v4

    - name: 'Run Checkov'
      uses: bridgecrewio/checkov-action@master
      with:
        directory: terraform/
        framework: terraform
        output_format: sarif
        output_file_path: checkov-results.sarif
        soft_fail: true

    - name: 'Upload Checkov Results'
      uses: github/codeql-action/upload-sarif@v3
      if: always()
      with:
        sarif_file: checkov-results.sarif
EOF
```

### 📡 Subtask 6.3: Add Drift Detection

**1️⃣ Create a workflow to detect configuration drift:**
```yaml
# Create drift detection workflow
cat > .github/workflows/drift-detection.yml << 'EOF'
name: 'Drift Detection'

on:
  schedule:
    - cron: '0 9 * * MON'  # Run every Monday at 9 AM
  workflow_dispatch:

env:
  TF_VERSION: '1.6.6'
  TF_WORKING_DIR: './terraform'

jobs:
  drift-detection:
    name: 'Detect Configuration Drift'
    runs-on: ubuntu-latest

    defaults:
      run:
        working-directory: ${{ env.TF_WORKING_DIR }}

    steps:
    - name: 'Checkout'
      uses: actions/checkout@v4

    - name: 'Setup Terraform'
      uses: hashicorp/setup-terraform@v3
      with:
        terraform_version: ${{ env.TF_VERSION }}

    - name: 'Terraform Init'
      run: terraform init

    - name: 'Terraform Plan'
      id: plan
      run: |
        terraform plan -detailed-exitcode -no-color -out=drift_plan || exit_code=$?
        echo "exit_code=$exit_code" >> $GITHUB_OUTPUT
        if [ $exit_code -eq 2 ]; then
          echo "drift_detected=true" >> $GITHUB_OUTPUT
          terraform show -no-color drift_plan > drift_details.txt
        else
          echo "drift_detected=false" >> $GITHUB_OUTPUT
        fi

    - name: 'Create Issue for Drift'
      if: steps.plan.outputs.drift_detected == 'true'
      uses: actions/github-script@v7
      with:
        github-token: ${{ secrets.GITHUB_TOKEN }}
        script: |
          const fs = require('fs');
          const driftDetails = fs.readFileSync('terraform/drift_details.txt', 'utf8');

          github.rest.issues.create({
            owner: context.repo.owner,
            repo: context.repo.repo,
            title: 'Configuration Drift Detected',
            body: `Configuration drift has been detected in the Terraform state.

            **Detection Time:** ${new Date().toISOString()}
            **Branch:** ${context.ref}
            **Commit:** ${context.sha}

            <details><summary>Drift Details</summary>

            \`\`\`terraform
            ${driftDetails}
            \`\`\`

            </details>

            Please review and apply the necessary changes to resolve the drift.`,
            labels: ['infrastructure', 'drift-detection', 'urgent']
          });
EOF
```

### 💾 Subtask 6.4: Commit and Test Advanced Features

**1️⃣ Commit the advanced CI/CD features and test them:**
```bash
# 💾 Add and commit new workflows
git add .github/workflows/
git commit -m "Add advanced CI/CD features: staging deployment, security scanning, and drift detection"
git push origin main

# 🌿 Create develop branch for staging workflow
git checkout -b develop
git push -u origin develop

# 🧪 Test manual drift detection
gh workflow run drift-detection.yml

# 📋 Check workflow status
gh run list --limit 10
```

---

## ✅ Task 7: Testing and Validation

### 🔄 Subtask 7.1: Test Complete CI/CD Flow

**1️⃣ Test the complete CI/CD flow with a comprehensive change:**
```bash
# 🌿 Create a new feature branch
git checkout main
git pull origin main
git checkout -b feature/add-configuration-file

# ➕ Add a new resource to create a configuration file
cat >> terraform/main.tf << 'EOF'

# 📄 Create a configuration file
resource "local_file" "config" {
  filename = "${path.module}/generated/config-${var.environment}.yaml"
  content = yamlencode({
    application = {
      name        = var.project_name
      environment = var.environment
      version     = "1.0.0"
    }
    infrastructure = {
      file_count    = var.file_count
      random_suffix = random_string.suffix.result
      created_at    = timestamp()
    }
    metadata = {
      terraform_version = "1.6.6"
      managed_by       = "terraform"
      ci_cd_pipeline   = "github-actions"
    }
  })
}
EOF

# ➕ Update outputs to include the new file
cat >> terraform/outputs.tf << 'EOF'

output "config_file" {
  description = "Configuration file location"
  value       = local_file.config.filename
}
EOF

# 💾 Commit and push changes
git add .
git commit -m "Add YAML configuration file resource"
git push -u origin feature/add-configuration-file

# 📬 Create pull request
gh pr create --title "Add YAML configuration file" --body "This PR adds a new YAML configuration file resource that contains application and infrastructure metadata."
```

### 👀 Subtask 7.2: Monitor and Validate Workflows

**1️⃣ Monitor the workflows and validate their execution:**
```bash
# 👀 Watch the plan workflow
gh run watch

# 🔀 After the plan completes, merge the PR
gh pr merge --merge

# 🔄 Switch to main and monitor apply workflow
git checkout main
git pull origin main
gh run watch

# ⬇️ Download and inspect the latest artifacts
LATEST_RUN_ID=$(gh run list --workflow="terraform-apply.yml" --limit 1 --json databaseId --jq '.[0].databaseId')
gh run download $LATEST_RUN_ID

# 📄 Check the generated configuration file
cat terraform-generated-files/config-*.yaml
```

### 🛑 Subtask 7.3: Test Destroy Workflow

**1️⃣ Test the manual destroy workflow:**
```bash
# 🛑 Trigger the destroy workflow
gh workflow run terraform-destroy.yml --field confirm_destroy=destroy

# 👀 Monitor the destroy workflow
gh run watch

# ✅ Verify destruction completed successfully
gh run list --workflow="terraform-destroy.yml" --limit 1
```

---

## 🛠️ Troubleshooting Common Issues

<details>
<summary>❗ Issue 1: Terraform State Lock</summary>

If you encounter state lock issues:
```bash
# ⚠️ Force unlock (use with caution)
cd terraform
terraform force-unlock <LOCK_ID>
```
</details>

<details>
<summary>❗ Issue 2: GitHub Actions Permission Issues</summary>

If workflows fail due to permissions:
1. Go to repository **Settings > Actions > General**
2. Ensure **"Read and write permissions"** is selected
3. Check **"Allow GitHub Actions to create and approve pull requests"**
</details>

<details>
<summary>❗ Issue 3: Workflow Not Triggering</summary>

If workflows don't trigger:
```bash
# 🔍 Check workflow syntax
gh workflow list
gh workflow view terraform-plan.yml
```
</details>

<details>
<summary>❗ Issue 4: Terraform Version Mismatch</summary>

If there are version compatibility issues:
```bash
# 🔧 Update Terraform version in workflows
sed -i 's/TF_VERSION: .*/TF_VERSION: "1.6.6"/' .github/workflows/*.yml
```
</details>

---

## 🏆 Best Practices Implemented

This lab demonstrates several CI/CD best practices:

| Practice | Description |
|----------|--------------|
| 🔀 Separation of Plan and Apply | Plans are generated on pull requests, applies happen on merge |
| 🌎 Environment Protection | Different workflows for different environments |
| 🔒 Security Scanning | Automated security checks with Checkov |
| 📡 Drift Detection | Scheduled checks for configuration drift |
| 📦 Artifact Management | Storing and versioning generated files |
| 🛑 Manual Approval Gates | Destroy operations require manual confirmation |
| 📋 Comprehensive Logging | Detailed output and artifact collection |

---

## 🏁 Conclusion

In this lab, you have successfully:

- ✅ Set up a complete CI/CD pipeline for Terraform using GitHub Actions
- ✅ Implemented automated `terraform plan` on pull requests and `terraform apply` on merge to main
- ✅ Created environment-specific deployment workflows
- ✅ Added security scanning and drift detection capabilities
- ✅ Tested the entire CI/CD flow with infrastructure changes
- ✅ Learned best practices for Infrastructure as Code in production environments

This CI/CD setup ensures that infrastructure changes are:

- 👀 **Reviewed** before implementation through pull request workflows
- 🧪 **Tested** automatically with validation and security scanning
- 🔁 **Applied** consistently using automated workflows
- 📡 **Monitored** for drift and compliance issues
- 📋 **Documented** through comprehensive logging and artifact storage

### 🌍 Real-World Applications

The skills you've learned in this lab are directly applicable to production environments where Infrastructure as Code practices are essential for maintaining reliable, scalable, and secure cloud infrastructure. The automated workflows reduce human error, improve consistency, and provide audit trails for all infrastructure changes.

---

<div align="center">

![Al Nafi](https://img.shields.io/badge/Al%20Nafi-Cybersecurity%20Training-blueviolet?style=for-the-badge)

</div>
