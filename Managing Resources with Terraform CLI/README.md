<div align="center">

# 🧰 Managing Resources with Terraform CLI

### Resource Targeting, State Manipulation, Tainting, and Dependency Management

![Terraform](https://img.shields.io/badge/Terraform-844FBA?style=for-the-badge&logo=terraform&logoColor=white)
![Terraform State](https://img.shields.io/badge/Terraform%20State-5C4EE5?style=for-the-badge&logo=terraform&logoColor=white)
![Bash](https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![GNU Nano](https://img.shields.io/badge/GNU%20Nano-4D4D4D?style=for-the-badge&logo=gnu&logoColor=white)
![IaC](https://img.shields.io/badge/Infrastructure%20as%20Code-000000?style=for-the-badge&logo=shieldsdotio&logoColor=white)

</div>

---

## 📋 Table of Contents

- [🎯 Lab Objectives](#-lab-objectives)
- [📌 Prerequisites](#-prerequisites)
- [🖥️ Lab Environment](#️-lab-environment)
- [🚀 Task 1: Environment Setup and Initial Infrastructure](#-task-1-environment-setup-and-initial-infrastructure)
- [🎯 Task 2: Resource Targeting and State Manipulation](#-task-2-resource-targeting-and-state-manipulation)
- [🧹 Task 3: Resource Removal and Cleanup](#-task-3-resource-removal-and-cleanup)
- [🔗 Task 4: Advanced Resource Management Scenarios](#-task-4-advanced-resource-management-scenarios)
- [🛠️ Troubleshooting Tips](#️-troubleshooting-tips)
- [🏆 Best Practices Demonstrated](#-best-practices-demonstrated)
- [🏁 Conclusion](#-conclusion)

---

## 🎯 Lab Objectives

By the end of this lab, you will be able to:

| # | Objective |
|---|-----------|
| 1 | 🩹 Use `terraform taint` to mark resources for recreation |
| 2 | 🗃️ Manipulate Terraform state using `terraform state` commands |
| 3 | 🎯 Apply changes to individual resources using resource targeting |
| 4 | 🧹 Remove specific resources using `terraform destroy` with targeting |
| 5 | 🔗 Understand the relationship between Terraform state and actual infrastructure |
| 6 | ⚙️ Practice advanced Terraform CLI operations for resource management |

---

## 📌 Prerequisites

| Requirement | Details |
|-------------|---------|
| 💻 Linux CLI | Basic understanding of Linux command line operations |
| 🌍 Terraform Basics | Familiarity with Terraform basics (resources, providers, state) |
| 🏗️ IaC Concepts | Knowledge of infrastructure as code concepts |
| ✏️ Text Editors | Understanding of file editing using text editors like `nano` or `vim` |

---

## 🖥️ Lab Environment

> 💡 Al Nafi provides Linux-based cloud machines for this lab. Simply click **Start Lab** to access your dedicated Linux machine. The provided machine is **bare metal with no pre-installed tools** — you will install all required tools during the lab exercises.

---

## 🚀 Task 1: Environment Setup and Initial Infrastructure

### 📦 Subtask 1.1: Install Required Tools

**1️⃣ Update your system and install necessary packages:**
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y wget unzip curl
```

### 🌍 Subtask 1.2: Install Terraform

**1️⃣ Download and install the latest version of Terraform:**
```bash
wget https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_linux_amd64.zip
unzip terraform_1.6.6_linux_amd64.zip
sudo mv terraform /usr/local/bin/
terraform version
```

### 📁 Subtask 1.3: Create Lab Directory Structure

**1️⃣ Set up your working directory:**
```bash
mkdir -p ~/terraform-lab16
cd ~/terraform-lab16
```

### 📝 Subtask 1.4: Create Initial Terraform Configuration

**1️⃣ Create a main configuration file with multiple resources:**
```bash
nano main.tf
```

**2️⃣ Add the following content:**
```hcl
terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

# 📄 Local file resources
resource "local_file" "app_config" {
  filename = "${path.module}/app-config.txt"
  content  = <<-EOT
    Application Configuration
    Environment: Development
    Version: 1.0.0
    Database: localhost:5432
    Cache: redis://localhost:6379
  EOT
}

resource "local_file" "database_config" {
  filename = "${path.module}/database-config.txt"
  content  = <<-EOT
    Database Configuration
    Host: localhost
    Port: 5432
    Database: myapp_dev
    Username: developer
    SSL: enabled
  EOT
}

resource "local_file" "nginx_config" {
  filename = "${path.module}/nginx.conf"
  content  = <<-EOT
    server {
        listen 80;
        server_name localhost;

        location / {
            proxy_pass http://localhost:3000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
    }
  EOT
}

# ⚙️ Null resources for demonstration
resource "null_resource" "app_setup" {
  provisioner "local-exec" {
    command = "echo 'Application setup completed' > app-setup.log"
  }

  depends_on = [local_file.app_config]
}

resource "null_resource" "database_setup" {
  provisioner "local-exec" {
    command = "echo 'Database setup completed at $(date)' > database-setup.log"
  }

  depends_on = [local_file.database_config]
}
```

### ▶️ Subtask 1.5: Initialize and Apply Initial Configuration

**1️⃣ Initialize Terraform and create the initial infrastructure:**
```bash
terraform init
terraform plan
terraform apply -auto-approve
```

**2️⃣ Verify the created resources:**
```bash
ls -la *.txt *.conf *.log
cat app-config.txt
cat database-config.txt
```

> 🎓 **TODO:** Before Task 2, run `terraform state list` once and note how many resources it shows — you'll compare this count after every targeting, taint, and state operation that follows.

---

## 🎯 Task 2: Resource Targeting and State Manipulation

### 🔍 Subtask 2.1: Explore Terraform State

**1️⃣ Examine the current state:**
```bash
terraform state list
```

**2️⃣ Get detailed information about a specific resource:**
```bash
terraform state show local_file.app_config
terraform state show null_resource.app_setup
```

### 🧩 Subtask 2.2: Practice Resource Targeting

**1️⃣ Create a new configuration file to modify specific resources:**
```bash
nano variables.tf
```

**2️⃣ Add the following content:**
```hcl
variable "app_version" {
  description = "Application version"
  type        = string
  default     = "1.0.0"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "development"
}
```

**3️⃣ Update the `main.tf` file to use variables:**
```bash
nano main.tf
```

**4️⃣ Modify the `app_config` resource:**
```hcl
resource "local_file" "app_config" {
  filename = "${path.module}/app-config.txt"
  content  = <<-EOT
    Application Configuration
    Environment: ${var.environment}
    Version: ${var.app_version}
    Database: localhost:5432
    Cache: redis://localhost:6379
    Updated: ${timestamp()}
  EOT
}
```

### 🎯 Subtask 2.3: Apply Changes to Specific Resources

**1️⃣ Apply changes only to the `app_config` resource:**
```bash
terraform plan -target=local_file.app_config
terraform apply -target=local_file.app_config -auto-approve
```

**2️⃣ Verify the change:**
```bash
cat app-config.txt
```

**3️⃣ Apply changes with variable overrides:**
```bash
terraform apply -target=local_file.app_config -var="app_version=1.1.0" -var="environment=staging" -auto-approve
```

**4️⃣ Check the updated content:**
```bash
cat app-config.txt
```

### 🩹 Subtask 2.4: Using Terraform Taint

**1️⃣ Mark a resource as tainted to force recreation:**
```bash
terraform taint null_resource.database_setup
```

**2️⃣ Check the plan to see what will be recreated:**
```bash
terraform plan
```

**3️⃣ Apply the changes to recreate the tainted resource:**
```bash
terraform apply -auto-approve
```

**4️⃣ Verify the database setup log was recreated with a new timestamp:**
```bash
cat database-setup.log
```

### 🗂️ Subtask 2.5: Advanced State Operations

**1️⃣ Move a resource in the state:**
```bash
terraform state mv local_file.nginx_config local_file.web_server_config
```

**2️⃣ Verify the state change:**
```bash
terraform state list
```

**3️⃣ Update the configuration to match the new resource name:**
```bash
nano main.tf
```

**4️⃣ Change the resource name from `nginx_config` to `web_server_config`:**
```hcl
resource "local_file" "web_server_config" {
  filename = "${path.module}/nginx.conf"
  content  = <<-EOT
    server {
        listen 80;
        server_name localhost;

        location / {
            proxy_pass http://localhost:3000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
    }
  EOT
}
```

**5️⃣ Run `terraform plan` to ensure no changes are needed:**
```bash
terraform plan
```

---

## 🧹 Task 3: Resource Removal and Cleanup

### 🗑️ Subtask 3.1: Remove Individual Resources

**1️⃣ Remove a specific resource using destroy with targeting:**
```bash
terraform destroy -target=null_resource.app_setup -auto-approve
```

**2️⃣ Verify the resource was removed:**
```bash
terraform state list
ls -la app-setup.log
```

### 📤 Subtask 3.2: Remove Resources from State Without Destroying

**1️⃣ Remove a resource from state without destroying the actual file:**
```bash
terraform state rm local_file.database_config
```

**2️⃣ Verify the resource is removed from state but file still exists:**
```bash
terraform state list
ls -la database-config.txt
```

### 📥 Subtask 3.3: Import Resources Back to State

**1️⃣ Import the removed resource back to state:**
```bash
terraform import local_file.database_config ./database-config.txt
```

**2️⃣ Verify the resource is back in state:**
```bash
terraform state list
terraform state show local_file.database_config
```

### ➕ Subtask 3.4: Create Additional Resources for Cleanup Demo

**1️⃣ Add more resources to demonstrate cleanup:**
```bash
nano cleanup-demo.tf
```

**2️⃣ Add the following content:**
```hcl
resource "local_file" "temp_file_1" {
  filename = "${path.module}/temp1.txt"
  content  = "Temporary file 1 for cleanup demonstration"
}

resource "local_file" "temp_file_2" {
  filename = "${path.module}/temp2.txt"
  content  = "Temporary file 2 for cleanup demonstration"
}

resource "null_resource" "cleanup_demo" {
  provisioner "local-exec" {
    command = "echo 'Cleanup demo resource created' > cleanup-demo.log"
  }
}
```

**3️⃣ Apply the new resources:**
```bash
terraform apply -auto-approve
```

### ✂️ Subtask 3.5: Selective Resource Destruction

**1️⃣ Destroy only the temporary files:**
```bash
terraform destroy -target=local_file.temp_file_1 -target=local_file.temp_file_2 -auto-approve
```

**2️⃣ Verify selective destruction:**
```bash
ls -la temp*.txt
terraform state list
```

### 🧼 Subtask 3.6: Complete Infrastructure Cleanup

**1️⃣ Finally, destroy all remaining resources:**
```bash
terraform destroy -auto-approve
```

**2️⃣ Verify all managed resources are removed:**
```bash
ls -la *.txt *.conf *.log
terraform state list
```

---

## 🔗 Task 4: Advanced Resource Management Scenarios

### 🧩 Subtask 4.1: Resource Dependencies and Targeting

**1️⃣ Create a new configuration with complex dependencies:**
```bash
nano advanced-demo.tf
```

**2️⃣ Add the following content:**
```hcl
resource "local_file" "base_config" {
  filename = "${path.module}/base.conf"
  content  = "Base configuration file"
}

resource "local_file" "app_specific_config" {
  filename = "${path.module}/app.conf"
  content  = "App configuration depends on: ${local_file.base_config.filename}"
}

resource "null_resource" "service_start" {
  provisioner "local-exec" {
    command = "echo 'Service started with configs: ${local_file.base_config.filename}, ${local_file.app_specific_config.filename}' > service.log"
  }

  depends_on = [
    local_file.base_config,
    local_file.app_specific_config
  ]
}
```

**3️⃣ Apply the configuration:**
```bash
terraform apply -auto-approve
```

### 🔍 Subtask 4.2: Understanding Dependency Impact

**1️⃣ Try to destroy only the base config and observe the plan:**
```bash
terraform plan -destroy -target=local_file.base_config
```

**2️⃣ Notice how Terraform handles dependencies. Apply the targeted destruction:**
```bash
terraform destroy -target=local_file.base_config -auto-approve
```

**3️⃣ Check what happened to dependent resources:**
```bash
terraform plan
cat service.log
```

### 💾 Subtask 4.3: State Backup and Recovery

**1️⃣ Create a state backup:**
```bash
cp terraform.tfstate terraform.tfstate.backup
```

**2️⃣ Make some changes and create a problematic state:**
```bash
terraform taint null_resource.service_start
terraform apply -auto-approve
```

**3️⃣ Restore from backup if needed:**
```bash
cp terraform.tfstate.backup terraform.tfstate
terraform plan
```

### 🧹 Subtask 4.4: Final Cleanup

**1️⃣ Remove all resources and clean up the workspace:**
```bash
terraform destroy -auto-approve
rm -f *.tf *.txt *.conf *.log *.backup
ls -la
```

---

## 🛠️ Troubleshooting Tips

<details>
<summary>❗ Terraform state lock errors</summary>

**Solution:**
```bash
terraform force-unlock <LOCK_ID>
```
</details>

<details>
<summary>❗ Resource not found in state</summary>

**Solution:** Use `terraform import` to add existing resources to state.
</details>

<details>
<summary>❗ Dependency conflicts during targeted operations</summary>

**Solution:** Include dependent resources in the target list or use the `-refresh=false` flag.
</details>

<details>
<summary>❗ State file corruption</summary>

**Solution:** Restore from backup or use `terraform refresh` to rebuild state.
</details>

---

## 🏆 Best Practices Demonstrated

| Practice | Why It Matters |
|----------|------------------|
| 💾 Always backup state files before major operations | Protects against corruption or unintended loss during risky commands |
| 🎯 Use resource targeting carefully to avoid breaking dependencies | Targeted operations can leave dependent resources in an inconsistent state |
| 🔀 Understand the difference between removing from state vs. destroying resources | `state rm` only forgets a resource; `destroy -target` actually deletes it |
| 👀 Use `terraform plan` before any destructive operations | Surfaces exactly what will change before it happens |
| 🔗 Keep track of resource dependencies when using targeted operations | Prevents surprises when Terraform pulls in dependent resources automatically |

---

## 🏁 Conclusion

In this lab, you have successfully learned advanced Terraform CLI resource management techniques. You practiced:

- 🎯 **Resource targeting** — applying changes to specific resources without affecting others
- 🗃️ **State manipulation** — using `terraform state` commands to move, remove, and import resources
- 🩹 **Resource tainting** — forcing recreation of specific resources
- ✂️ **Selective destruction** — removing only targeted resources
- 🔗 **Dependency management** — understanding how Terraform handles resource relationships

These skills are essential for managing complex infrastructure deployments where you need fine-grained control over resource lifecycle management. Understanding these advanced CLI operations allows you to:

- 🛠️ Troubleshoot infrastructure issues more effectively
- 🔧 Perform maintenance operations without full infrastructure recreation
- 📐 Manage large-scale deployments with precision
- 💾 Handle state file issues and recovery scenarios

### 🌍 Real-World Applications

The techniques you learned in this lab are crucial for production Terraform usage, where careful resource management can prevent downtime and reduce deployment risks. Practice these commands in safe environments before applying them to production infrastructure.

---

<div align="center">

![Al Nafi](https://img.shields.io/badge/Al%20Nafi-Cybersecurity%20Training-blueviolet?style=for-the-badge)

</div>
