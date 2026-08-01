<div align="center">

# 🏛️ Terraform Ecosystem and Best Practices

### Reusable Module Libraries, Environment Isolation, and Fully Automated Lifecycle Orchestration

![Terraform](https://img.shields.io/badge/Terraform-844FBA?style=for-the-badge&logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Bash](https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)
![Git](https://img.shields.io/badge/Git-F05032?style=for-the-badge&logo=git&logoColor=white)
![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)
![IaC](https://img.shields.io/badge/Infrastructure%20as%20Code-000000?style=for-the-badge&logo=shieldsdotio&logoColor=white)

</div>

---

## 📋 Table of Contents

- [🎯 Objectives](#-objectives)
- [📌 Prerequisites](#-prerequisites)
- [🖥️ Lab Environment](#️-lab-environment)
- [🧰 Task 1: Install and Verify the Terraform Toolchain](#-task-1-install-and-verify-the-terraform-toolchain)
- [🧱 Task 2: Design and Build a Reusable Terraform Module Library](#-task-2-design-and-build-a-reusable-terraform-module-library)
- [⚙️ Task 3: Automate the Terraform Lifecycle with an Orchestration Script](#️-task-3-automate-the-terraform-lifecycle-with-an-orchestration-script)
- [🏆 Expected Outcomes](#-expected-outcomes)
- [🧠 Key Concepts](#-key-concepts)
- [🏁 Conclusion](#-conclusion)

---

## 🎯 Objectives

| # | Objective |
|---|-----------|
| 1 | 🧩 Design and publish a reusable, multi-module Terraform library that enforces input validation and exposes typed outputs |
| 2 | 🌎 Implement environment-scoped infrastructure configurations that consume local modules and demonstrate state isolation |
| 3 | ⚙️ Automate the full Terraform lifecycle (init, validate, plan, apply, destroy) using a shell-based orchestration script with error handling |

---

## 📌 Prerequisites

| Requirement | Details |
|-------------|---------|
| 💻 Linux CLI | Comfort with Linux command-line operations including file editing, directory navigation, and shell scripting |
| 🏗️ IaC Concepts | Conceptual understanding of infrastructure as code: what state files are, why idempotency matters, and how provider plugins work |

---

## 🖥️ Lab Environment

> 💡 You will work on a dedicated AWS EC2 Ubuntu instance provided by Al Nafi. The instance has a **base Ubuntu installation**; you will install all required tools in Task 1.

---

## 🧰 Task 1: Install and Verify the Terraform Toolchain

> **Step 1:** Install Terraform, Git, and supporting utilities. Run the following commands exactly as written. The HashiCorp APT repository is used so that future `apt upgrade` commands keep Terraform current.

```bash
sudo apt-get update -y
sudo apt-get install -y gnupg software-properties-common curl wget unzip git tree

# 🔑 Add HashiCorp GPG key
curl -fsSL https://apt.releases.hashicorp.com/gpg \
  | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
```

> 📖 Official installation guide (use this if the URL above changes): https://developer.hashicorp.com/terraform/install#linux

```bash
# 📦 Add HashiCorp APT repository — written as a single line via printf to avoid backslash corruption
printf 'deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com %s main\n' \
  "$(lsb_release -cs)" \
  | sudo tee /etc/apt/sources.list.d/hashicorp.list
```

<details>
<summary>🛠️ Troubleshoot this step</summary>

**Error seen:** `E: Malformed entry 1 in list file /etc/apt/sources.list.d/hashicorp.list` — this means a literal backslash was written into the file.

**Recovery:** Run `cat /etc/apt/sources.list.d/hashicorp.list` — the file must be a single unbroken line; delete it with `sudo rm /etc/apt/sources.list.d/hashicorp.list` and re-run the `printf` command above.
📖 Official docs: https://developer.hashicorp.com/terraform/install#linux
</details>

```bash
sudo apt-get update -y
sudo apt-get install -y terraform
```

### ✅ Step 2: Verify Every Installed Tool and Configure Git

```bash
terraform version
git --version
tree --version
```

> ✅ You should see a Terraform version line beginning with `Terraform v1.` and no error output. If any command returns `command not found`, the installation in Step 1 did not complete successfully.

```bash
git config --global user.name "Lab Student"
git config --global user.email "student@alnafi.lab"
```

> ✅ **Confirmation:** `git config --global --list` must print both `user.name` and `user.email` without error.

---

## 🧱 Task 2: Design and Build a Reusable Terraform Module Library

> ⚠️ No starter templates are provided for this task. Design and implement the module library **entirely your own work**.

### 📜 Problem Statement

Design and implement a local Terraform module library containing **at least two modules**:

| Module | Scope |
|--------|-------|
| 🌐 Networking | VPC, subnets, route tables |
| 🖥️ Compute | Security group, EC2 instances via a launch template |

**Each module must:**
- ✅ Enforce input constraints using `validation` blocks
- 📤 Expose a complete set of typed outputs
- 📌 Include a `versions.tf` file that pins the required Terraform version and AWS provider version
- 🚫 Contain **no hard-coded values** — every configurable attribute must be an input variable with a description and type constraint

**Layout and wiring requirements:**
- 📁 The module library must live under a `modules/` directory
- 🔗 A consumer configuration under `environments/dev/` must call both modules, wiring the networking module's outputs into the compute module's inputs
- ✅ It must produce a `terraform plan` that exits with code `0` using the `hashicorp/aws` provider pointed at a local mock endpoint (**LocalStack** or a **null provider** — your choice of mock strategy)

### ✅ Acceptance Criteria

| ✔️ | Criterion |
|---|-----------|
| ☐ | `terraform validate` inside `environments/dev/` exits with code `0` and prints `Success! The configuration is valid.` — no warnings, no errors |
| ☐ | Every input variable in both modules has a type, a description, and at least one `validation` block |
| ☐ | Running `terraform plan` with a deliberately invalid input value (e.g. a VPC CIDR that is not valid CIDR notation) causes Terraform to exit with a **non-zero code** and print the custom `error_message` from the validation block |

> 🎓 **TODO:** Write the `validation` block and its `error_message` for your VPC CIDR variable *before* writing the resource block that consumes it — deciding the failure message first keeps the constraint honest.

---

## ⚙️ Task 3: Automate the Terraform Lifecycle with an Orchestration Script

> ⚠️ No starter templates are provided for this task. Design and implement `tf-orchestrate.sh` **entirely your own work**.

### 📜 Problem Statement

Design and implement a single Bash orchestration script named `tf-orchestrate.sh` that accepts **one positional argument** — the target environment name (`dev`, `staging`, or `prod`) — and executes the full Terraform lifecycle for that environment in the correct order:

| Stage | Behavior |
|-------|----------|
| 1️⃣ Tool-version check | Confirms required tools are present before proceeding |
| 2️⃣ `init` | Initializes the target environment |
| 3️⃣ `validate` | Validates the configuration |
| 4️⃣ `plan` | Saves the plan to a binary file named `<environment>.tfplan` |
| 5️⃣ Gated `apply` | Only proceeds if the plan file exists **and** the user explicitly confirms |

**Error-handling requirement:** If any Terraform command exits with a non-zero code, the script must print a descriptive message identifying which stage failed and exit with a non-zero code itself, **without continuing to the next stage**.

**Destroy sub-command:** The script must also support a `destroy` sub-command (`./tf-orchestrate.sh dev destroy`) that runs `terraform destroy -auto-approve` only **after** printing a ten-second countdown warning that can be interrupted with `Ctrl-C`.

### ✅ Acceptance Criteria

| ✔️ | Criterion |
|---|-----------|
| ☐ | `./tf-orchestrate.sh dev` completes the init-validate-plan sequence, writes `dev.tfplan` to disk, prompts for confirmation before apply, and exits with code `0` when the user confirms |
| ☐ | If any intermediate stage fails, the script exits immediately with a non-zero code and a message naming the failed stage (verified by introducing a syntax error into `environments/dev/main.tf` and confirming the script stops at the validate stage) |
| ☐ | `./tf-orchestrate.sh dev destroy` prints a visible ten-second countdown to stderr and can be cancelled with `Ctrl-C` before the countdown ends |
| ☐ | If not cancelled, the destroy command executes `terraform destroy -auto-approve` and exits with code `0` |
| ☐ | The script refuses to run at all if called with an environment name other than `dev`, `staging`, or `prod`, printing a usage message and exiting with code `1` |

---

## 🏆 Expected Outcomes

- 🧩 A version-controlled repository containing a two-module Terraform library, two environment configurations, and a fully error-handled orchestration script that manages the complete infrastructure lifecycle without manual Terraform commands
- ✅ Both acceptance criteria in Task 2 and both acceptance criteria in Task 3 pass demonstrably: `terraform validate` succeeds, invalid inputs produce custom error messages, the orchestration script gates apply behind confirmation, and the destroy countdown is interruptible

---

## 🧠 Key Concepts

| Concept | Tool / Technique | Purpose |
|---------|-------------------|---------|
| 🧩 Module Boundaries | Separate `modules/networking/` and `modules/compute/` | Keeps concerns isolated and each module independently reusable |
| ✅ Input Contracts | `validation {}` blocks with custom `error_message` | Rejects bad input at `plan` time with a message that explains *why* |
| 📌 Version Pinning | `versions.tf` per module | Prevents silent breakage from Terraform/provider upgrades |
| 🌎 Environment Isolation | `environments/dev/` consumer configuration | Keeps environment-specific wiring separate from reusable module logic |
| 🧪 Mock Infrastructure | LocalStack or `null` provider | Lets `terraform plan`/`apply` succeed without real AWS credentials or cost |
| ⚙️ Lifecycle Orchestration | `tf-orchestrate.sh` (init→validate→plan→gated apply) | Encodes the safe sequence a human would follow manually, with a confirmation gate before anything destructive |
| ⏱️ Interruptible Safety Gate | 10-second countdown before `destroy -auto-approve` | Gives a last chance to cancel a destructive action before it's automated away |

---

## 🏁 Conclusion

This lab required you to make architectural decisions — module boundaries, variable contracts, output shapes, and error-handling strategy — without prescribed steps, which mirrors real infrastructure engineering work. The orchestration script pattern you built is the foundation of CI/CD pipeline integration for Terraform, where the same init-validate-plan-apply sequence runs unattended with human approval gates. Extend this foundation by adding remote state backends and policy-as-code checks as your next self-directed challenge.

---

<div align="center">

![Al Nafi](https://img.shields.io/badge/Al%20Nafi-Cybersecurity%20Training-blueviolet?style=for-the-badge)

</div>
