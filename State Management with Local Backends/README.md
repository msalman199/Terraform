<div align="center">

# 🗂️ State Management with Local Backends

### Configuring, Inspecting, and Manipulating Terraform State

![Terraform](https://img.shields.io/badge/Terraform-844FBA?style=for-the-badge&logo=terraform&logoColor=white)
![Local%20Provider](https://img.shields.io/badge/Local%20Provider-2C2C2C?style=for-the-badge&logo=terraform&logoColor=white)
![Random%20Provider](https://img.shields.io/badge/Random%20Provider-844FBA?style=for-the-badge&logo=terraform&logoColor=white)
![JSON](https://img.shields.io/badge/JSON-000000?style=for-the-badge&logo=json&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)

**Difficulty:** 🟡 Intermediate &nbsp;|&nbsp; **Duration:** ⏱️ 90–120 minutes &nbsp;|&nbsp; **Track:** ☁️ Cloud DevOps

</div>

---

## 📑 Table of Contents

- [🎯 Lab Objectives](#-lab-objectives)
- [📋 Prerequisites](#-prerequisites)
- [🖥️ Lab Environment](#️-lab-environment)
- [🗃️ Task 1: Create a Local State Backend for Terraform State Files](#️-task-1-create-a-local-state-backend-for-terraform-state-files)
- [🚀 Task 2: Run Terraform Apply and Verify State File Changes](#-task-2-run-terraform-apply-and-verify-state-file-changes)
- [🔎 Task 3: Inspect and Manipulate Terraform State Using State Commands](#-task-3-inspect-and-manipulate-terraform-state-using-state-commands)
- [🛠️ Troubleshooting Common Issues](#️-troubleshooting-common-issues)
- [✅ Lab Verification](#-lab-verification)
- [🧠 Key Concepts](#-key-concepts)
- [🏁 Conclusion](#-conclusion)

---

## 🎯 Lab Objectives

By the end of this lab, you will be able to:

| # | Objective |
|---|-----------|
| 1 | 🗂️ Understand Terraform state management concepts and importance |
| 2 | ⚙️ Configure and implement local backend storage for Terraform state files |
| 3 | ▶️ Execute Terraform operations and observe state file modifications |
| 4 | 🔍 Use Terraform state commands to inspect and manipulate infrastructure state |
| 5 | 🛠️ Troubleshoot common state management issues in Terraform workflows |

---

## 📋 Prerequisites

| Requirement | Details |
|---|---|
| 🧩 Terraform Basics | Basic understanding of Terraform concepts and syntax |
| 🐧 Linux CLI | Familiarity with Linux command-line operations |
| 🧱 IaC Principles | Knowledge of infrastructure as code principles |
| 📝 Text Editors | Experience with `nano`, `vim`, or similar |
| 📁 File Systems | Understanding of file system navigation and permissions |

---

## 🖥️ Lab Environment

> 💡 **Note:** Al Nafi provides Linux-based cloud machines for this lab. Simply click **Start Lab** to access your dedicated environment. The machine is bare metal with no pre-installed tools — you will install all required software during the lab exercises.

![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?style=flat-square&logo=ubuntu&logoColor=white)

---

## 🗃️ Task 1: Create a Local State Backend for Terraform State Files

![Terraform](https://img.shields.io/badge/Terraform-844FBA?style=flat-square&logo=terraform&logoColor=white)
![Backend](https://img.shields.io/badge/Backend-local-2C2C2C?style=flat-square&logo=terraform&logoColor=white)

### ⬇️ Subtask 1.1: Install Required Tools

```bash
# 🔄 Update the system package manager
sudo apt update

# 📦 Install required packages
sudo apt install -y wget unzip curl

# ⬇️ Download Terraform (latest stable version)
wget https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_linux_amd64.zip
# TODO: Check releases.hashicorp.com/terraform for the current latest version before downloading

# 📦 Unzip Terraform binary
unzip terraform_1.6.6_linux_amd64.zip

# 📂 Move Terraform to system PATH
sudo mv terraform /usr/local/bin/

# ✅ Verify Terraform installation
terraform version

# 🧹 Clean up downloaded files
rm terraform_1.6.6_linux_amd64.zip
```

### 📂 Subtask 1.2: Create Project Directory Structure

```bash
# 📁 Create main project directory
mkdir -p ~/terraform-state-lab
cd ~/terraform-state-lab

# 🗄️ Create subdirectories for organization
mkdir -p {configs,state-files,backups}

# 👀 Create initial project structure
tree ~/terraform-state-lab || ls -la ~/terraform-state-lab
```

### ⚙️ Subtask 1.3: Configure Local Backend

```bash
# ✍️ Create the main configuration file
cat > ~/terraform-state-lab/main.tf << 'EOF'
# ⚙️ Configure Terraform settings and required providers
terraform {
  required_version = ">= 1.0"

  # 🗂️ Configure local backend for state storage
  backend "local" {
    path = "./state-files/terraform.tfstate"
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

# ☁️ Configure the local provider
provider "local" {}
provider "random" {}

# 🎲 Create a random string resource
resource "random_string" "lab_id" {
  length  = 8
  special = false
  upper   = false
}

# 📄 Create a local file resource
resource "local_file" "lab_info" {
  filename = "./configs/lab-${random_string.lab_id.result}.txt"
  content  = <<-EOT
    Lab 4: State Management with Local Backends
    Lab ID: ${random_string.lab_id.result}
    Created: ${timestamp()}
    Backend Type: Local
    State File Location: ./state-files/terraform.tfstate
  EOT
}

# 🔐 Create a sensitive file with restricted permissions
resource "local_sensitive_file" "credentials" {
  filename = "./configs/credentials-${random_string.lab_id.result}.txt"
  content  = <<-EOT
    # Sensitive Configuration File
    api_key: secret-key-${random_string.lab_id.result}
    database_password: db-pass-${random_string.lab_id.result}
  EOT
  file_permission = "0600"
}

# 📤 Output values for verification
output "lab_id" {
  value       = random_string.lab_id.result
  description = "Unique identifier for this lab session"
}

output "state_file_path" {
  value       = "./state-files/terraform.tfstate"
  description = "Path to the Terraform state file"
}

output "created_files" {
  value = [
    local_file.lab_info.filename,
    local_sensitive_file.credentials.filename
  ]
  description = "List of files created by Terraform"
}
EOF
```

### ⚙️ Subtask 1.4: Initialize Terraform with Local Backend

```bash
# 📍 Navigate to project directory
cd ~/terraform-state-lab

# ⚙️ Initialize Terraform (this creates the backend)
terraform init

# ✅ Verify initialization was successful
echo "Checking initialization results:"
ls -la .terraform/
ls -la state-files/ 2>/dev/null || echo "State files directory will be created on first apply"
```

### ✔️ Subtask 1.5: Validate Configuration

```bash
# ✔️ Validate the configuration syntax
terraform validate

# 🎨 Format the configuration files
terraform fmt

# 🗺️ Show the execution plan
terraform plan
```

> 🟢 **Sign-off:** Local backend configured, initialized, and validated — ready to apply.

---

## 🚀 Task 2: Run Terraform Apply and Verify State File Changes

![Terraform](https://img.shields.io/badge/Terraform-844FBA?style=flat-square&logo=terraform&logoColor=white)
![JSON](https://img.shields.io/badge/JSON-000000?style=flat-square&logo=json&logoColor=white)
![Python](https://img.shields.io/badge/Python%203-3776AB?style=flat-square&logo=python&logoColor=white)

### ▶️ Subtask 2.1: Execute Initial Terraform Apply

```bash
# 🚀 Apply the configuration
terraform apply -auto-approve

# ✅ Verify state file was created
echo "State file information:"
ls -la state-files/
file state-files/terraform.tfstate
```

### 🔬 Subtask 2.2: Examine State File Contents

```bash
# 📖 Display state file contents (formatted JSON)
echo "=== Terraform State File Contents ==="
cat state-files/terraform.tfstate | python3 -m json.tool

# 📏 Show state file size and modification time
stat state-files/terraform.tfstate
```

### 🔍 Subtask 2.3: Verify Created Resources

```bash
# 📁 List created files
echo "=== Created Files ==="
ls -la configs/

# 📄 Display content of the lab info file
echo "=== Lab Info File Content ==="
cat configs/lab-*.txt

# 🔐 Check permissions of sensitive file
echo "=== Sensitive File Permissions ==="
ls -la configs/credentials-*.txt
```

### ✏️ Subtask 2.4: Make Configuration Changes

```bash
# ➕ Add a new resource to the configuration
cat >> ~/terraform-state-lab/main.tf << 'EOF'

# 📄 Add another local file resource
resource "local_file" "additional_config" {
  filename = "./configs/additional-${random_string.lab_id.result}.json"
  content = jsonencode({
    lab_name    = "State Management Lab"
    lab_number  = 4
    backend     = "local"
    timestamp   = timestamp()
    lab_id      = random_string.lab_id.result
  })
}

# 📤 Add output for the new resource
output "additional_file" {
  value       = local_file.additional_config.filename
  description = "Path to additional configuration file"
}
EOF
```

### 🔁 Subtask 2.5: Apply Changes and Compare State

```bash
# 💾 Create backup of current state
cp state-files/terraform.tfstate backups/terraform.tfstate.backup1

# 🗺️ Show plan for changes
terraform plan

# 🚀 Apply the changes
terraform apply -auto-approve

# 📏 Compare state file sizes
echo "=== State File Size Comparison ==="
ls -la state-files/terraform.tfstate backups/terraform.tfstate.backup1

# 🔀 Show differences in state file content
echo "=== State File Differences ==="
diff backups/terraform.tfstate.backup1 state-files/terraform.tfstate || echo "Files differ as expected"
```

> 🟢 **Sign-off:** Resources applied, state file changes observed, and a state backup captured before the update.

---

## 🔎 Task 3: Inspect and Manipulate Terraform State Using State Commands

![Terraform](https://img.shields.io/badge/Terraform-844FBA?style=flat-square&logo=terraform&logoColor=white)
![CLI](https://img.shields.io/badge/CLI-000000?style=flat-square&logo=gnubash&logoColor=white)

### 📋 Subtask 3.1: List Resources in State

```bash
# 📋 List all resources in the state
echo "=== All Resources in State ==="
terraform state list

# 🔍 Show detailed information about specific resources
echo "=== Random String Resource Details ==="
terraform state show random_string.lab_id

echo "=== Local File Resource Details ==="
terraform state show local_file.lab_info
```

### 📥 Subtask 3.2: Pull and Examine State

```bash
# 📥 Pull the current state
terraform state pull > current-state.json

# 🔬 Display state structure
echo "=== State File Structure ==="
cat current-state.json | python3 -m json.tool | head -30

# 🧾 Show state metadata
echo "=== State Metadata ==="
cat current-state.json | python3 -c "
import json, sys
state = json.load(sys.stdin)
print(f'Terraform Version: {state.get(\"terraform_version\", \"N/A\")}')
print(f'Serial Number: {state.get(\"serial\", \"N/A\")}')
print(f'Resources Count: {len(state.get(\"resources\", []))}')
"
```

### 🔀 Subtask 3.3: Move Resources in State

```bash
# 📋 Show current state before moving
echo "=== Before Moving Resource ==="
terraform state list

# 🔀 Move a resource to a new name (rename in state)
terraform state mv local_file.additional_config local_file.moved_config

# ✅ Verify the move
echo "=== After Moving Resource ==="
terraform state list

# ✏️ Update configuration to match the new resource name
sed -i 's/local_file.additional_config/local_file.moved_config/g' main.tf

# ✔️ Verify configuration still works
terraform plan
```

### 🗑️ Subtask 3.4: Remove Resources from State

```bash
# 💾 Create backup before removal
cp state-files/terraform.tfstate backups/terraform.tfstate.backup2

# 🗑️ Remove a resource from state (but keep the actual file)
terraform state rm local_sensitive_file.credentials

# ✅ Verify removal
echo "=== Resources After Removal ==="
terraform state list

# 📄 Check that the actual file still exists
echo "=== Actual File Still Exists ==="
ls -la configs/credentials-*.txt
```

### 📤 Subtask 3.5: Import Resources Back to State

```bash
# 🔎 Get the filename of the credentials file
CRED_FILE=$(ls configs/credentials-*.txt)

# 📥 Import the resource back into state
terraform import local_sensitive_file.credentials "$CRED_FILE"

# ✅ Verify import was successful
echo "=== Resources After Import ==="
terraform state list

# 🗺️ Run plan to ensure everything is synchronized
terraform plan
```

### 📊 Subtask 3.6: Advanced State Inspection

```bash
# 📝 Create a comprehensive state report
cat > state-report.sh << 'EOF'
#!/bin/bash
echo "=== TERRAFORM STATE ANALYSIS REPORT ==="
echo "Generated on: $(date)"
echo ""

echo "1. STATE FILE INFORMATION:"
echo "   File: $(pwd)/state-files/terraform.tfstate"
echo "   Size: $(stat -c%s state-files/terraform.tfstate) bytes"
echo "   Modified: $(stat -c%y state-files/terraform.tfstate)"
echo ""

echo "2. RESOURCES IN STATE:"
terraform state list | nl
echo ""

echo "3. STATE METADATA:"
terraform state pull | python3 -c "
import json, sys
state = json.load(sys.stdin)
print(f'   Terraform Version: {state.get(\"terraform_version\", \"N/A\")}')
print(f'   Serial Number: {state.get(\"serial\", \"N/A\")}')
print(f'   Lineage: {state.get(\"lineage\", \"N/A\")}')
print(f'   Resources Count: {len(state.get(\"resources\", []))}')
"
echo ""

echo "4. OUTPUT VALUES:"
terraform output
echo ""

echo "5. CREATED FILES:"
ls -la configs/
echo ""

echo "=== END OF REPORT ==="
EOF

# 🔓 Make script executable and run it
chmod +x state-report.sh
./state-report.sh
```

> 🟢 **Sign-off:** State inspected, renamed, removed, and re-imported using the full `terraform state` command suite.

---

## 🛠️ Troubleshooting Common Issues

<details>
<summary>❌ State File Corruption</summary>

```bash
# Restore from backup
cp backups/terraform.tfstate.backup1 state-files/terraform.tfstate

# Verify restoration
terraform state list
```
</details>

<details>
<summary>❌ Backend Configuration Issues</summary>

```bash
# Remove .terraform directory and reinitialize
rm -rf .terraform
terraform init
```
</details>

<details>
<summary>❌ State Lock Issues</summary>

For state locking problems (though less common with local backend):

```bash
# Force unlock if needed (use with caution)
# terraform force-unlock LOCK_ID
```
</details>

---

## ✅ Lab Verification

Verify your lab completion with this check script:

```bash
# 📝 Final verification script
cat > verify-lab.sh << 'EOF'
#!/bin/bash
echo "=== LAB 4 VERIFICATION ==="

# Check 1: Terraform installation
if command -v terraform &> /dev/null; then
    echo "✓ Terraform is installed: $(terraform version --json | python3 -c 'import json,sys; print(json.load(sys.stdin)["terraform_version"])')"
else
    echo "✗ Terraform is not installed"
fi

# Check 2: State file exists
if [ -f "state-files/terraform.tfstate" ]; then
    echo "✓ State file exists"
else
    echo "✗ State file not found"
fi

# Check 3: Resources in state
RESOURCE_COUNT=$(terraform state list | wc -l)
if [ $RESOURCE_COUNT -gt 0 ]; then
    echo "✓ State contains $RESOURCE_COUNT resources"
else
    echo "✗ No resources found in state"
fi

# Check 4: Created files exist
if ls configs/*.txt &> /dev/null; then
    echo "✓ Configuration files created"
else
    echo "✗ Configuration files not found"
fi

# Check 5: Backup files exist
if ls backups/*.backup* &> /dev/null; then
    echo "✓ Backup files created"
else
    echo "✗ Backup files not found"
fi

echo "=== VERIFICATION COMPLETE ==="
EOF

chmod +x verify-lab.sh
./verify-lab.sh
```

> 🟢 **Sign-off:** All five verification checks pass — lab environment confirmed complete.

---

## 🧠 Key Concepts

| Concept | Description |
|---|---|
| 🗂️ Local Backend | Stores Terraform state on the local file system via a `backend "local"` block with a configurable `path` |
| 🧾 State File | A JSON file tracking resource attributes, dependencies, and metadata (`terraform_version`, `serial`, `lineage`) |
| 🔍 `terraform state list` / `show` | Inspect which resources are tracked and their detailed attributes |
| 📥 `terraform state pull` | Retrieves the raw state as JSON for external inspection or scripting |
| 🔀 `terraform state mv` | Renames or moves a resource within state without destroying/recreating it |
| 🗑️ `terraform state rm` / `terraform import` | Removes a resource from state tracking (without deleting it) or brings an existing resource back under management |
| 💾 State Backup & Recovery | Copying `terraform.tfstate` before changes enables restoration if corruption occurs |

---

## 🏁 Conclusion

In this lab, you have successfully:

- 🗂️ **Configured Local Backend Storage** — set up Terraform to use the local file system for state storage, understanding the backend configuration syntax and initialization process
- 📊 **Managed Infrastructure State** — applied Terraform configurations and observed how state files track resource information, dependencies, and metadata
- 🔧 **Manipulated State Files** — used various `terraform state` commands to inspect, move, remove, and import resources, gaining hands-on experience with state management operations
- 💾 **Implemented State Backup Strategies** — created backup copies of state files and learned recovery procedures for state file corruption scenarios
- 🔬 **Analyzed State Structure** — examined the JSON structure of Terraform state files and understood how Terraform tracks resource attributes and relationships

This lab provided practical experience with Terraform state management, which is crucial for maintaining infrastructure consistency and enabling team collaboration. Understanding local backends serves as a foundation for more advanced backend configurations like remote state storage with locking mechanisms.

### 🌍 Real-World Applications

The skills learned here are essential for:

- 🏭 **Production Infrastructure Management** — proper state handling prevents resource conflicts and data loss
- 👥 **Team Collaboration** — understanding state mechanics enables effective multi-developer workflows
- 🆘 **Disaster Recovery** — state backup and recovery procedures ensure infrastructure resilience
- 🧩 **Advanced Terraform Usage** — state manipulation commands are vital for complex infrastructure migrations and refactoring

Continue practicing these concepts as you progress to more advanced Terraform topics like remote backends, state locking, and collaborative infrastructure development.

---

<div align="center">

![Al Nafi](https://img.shields.io/badge/Al%20Nafi-Cybersecurity%20Training-blueviolet?style=for-the-badge)

</div>
