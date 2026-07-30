<div align="center">

# 🧱 Modular Design with Terraform

### Building Reusable EC2 Modules Across Dev, Test, and Prod Environments

![Terraform](https://img.shields.io/badge/Terraform-844FBA?style=for-the-badge&logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazonaws&logoColor=white)
![EC2](https://img.shields.io/badge/Amazon%20EC2-FF9900?style=for-the-badge&logo=amazonec2&logoColor=white)
![HCL](https://img.shields.io/badge/HCL-5C4EE5?style=for-the-badge&logo=terraform&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)

**Difficulty:** 🟡 Intermediate &nbsp;|&nbsp; **Duration:** ⏱️ 120–150 minutes &nbsp;|&nbsp; **Track:** ☁️ Cloud DevOps

</div>

---

## 📑 Table of Contents

- [🎯 Objectives](#-objectives)
- [📋 Prerequisites](#-prerequisites)
- [🖥️ Lab Environment](#️-lab-environment)
- [🧰 Task 1: Install and Verify Required Tools](#-task-1-install-and-verify-required-tools)
- [🧩 Task 2: Design and Build a Reusable EC2 Module](#-task-2-design-and-build-a-reusable-ec2-module)
- [🏗️ Task 3: Compose Environment Configurations Using the Module](#️-task-3-compose-environment-configurations-using-the-module)
- [📦 Expected Outcomes](#-expected-outcomes)
- [🧠 Key Concepts](#-key-concepts)
- [✅ Conclusion](#-conclusion)

---

## 🎯 Objectives

| # | Objective |
|---|-----------|
| 1 | 🧩 Design a reusable Terraform module that abstracts EC2 instance provisioning behind a clean variable interface |
| 2 | 🏗️ Compose multiple instances of that module into isolated environment configurations representing dev, test, and prod tiers |
| 3 | ✅ Validate module reusability by demonstrating that changing variable inputs alone produces meaningfully different infrastructure plans |

---

## 📋 Prerequisites

| Requirement | Details |
|---|---|
| 🐧 Linux CLI | Comfort navigating and editing files on an Ubuntu Linux command line |
| 🧩 Terraform Basics | Familiarity with providers, resources, variables, and outputs |

---

## 🖥️ Lab Environment

> 💡 **Note:** You will work on a dedicated AWS EC2 Ubuntu instance provided by Al Nafi. The instance has a base Ubuntu installation — you will install all required tools in Task 1.

![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?style=flat-square&logo=ubuntu&logoColor=white)
![EC2](https://img.shields.io/badge/Amazon%20EC2-FF9900?style=flat-square&logo=amazonec2&logoColor=white)

---

## 🧰 Task 1: Install and Verify Required Tools

![Terraform](https://img.shields.io/badge/Terraform-844FBA?style=flat-square&logo=terraform&logoColor=white)
![AWS%20CLI](https://img.shields.io/badge/AWS%20CLI-232F3E?style=flat-square&logo=amazonaws&logoColor=white)
![APT](https://img.shields.io/badge/APT-A81D33?style=flat-square&logo=debian&logoColor=white)

### 📥 Step 1: Install Terraform and the AWS CLI

Install both tools from their official distribution channels and confirm each binary is reachable on your `PATH`.

```bash
# 📦 Install system dependencies
sudo apt-get update -y
sudo apt-get install -y wget unzip curl gnupg software-properties-common

# 🔐 Add HashiCorp's GPG key and apt repository for Terraform
wget -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
```

📚 If the URL above fails, find the current key URL at: https://developer.hashicorp.com/terraform/install

```bash
printf 'deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com %s main\n' \
  "$(lsb_release -cs)" \
  | sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt-get update -y     # 🔄 pick up the new repo
sudo apt-get install -y terraform   # ⬇️ install Terraform CLI
```

<details>
<summary>🛠️ Troubleshoot this step</summary>

**Error seen:** `E: Malformed entry 1 in list file /etc/apt/sources.list.d/hashicorp.list`

**Recovery:** Run `cat /etc/apt/sources.list.d/hashicorp.list` — the file must be a single unbroken line with no backslashes. Delete it with `sudo rm /etc/apt/sources.list.d/hashicorp.list` and re-run the `printf` command above.

📚 Docs: https://developer.hashicorp.com/terraform/install

</details>

```bash
# ⬇️ Install AWS CLI v2
curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
```

📚 If the URL above fails, find the current download link at: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

```bash
unzip /tmp/awscliv2.zip -d /tmp/awscli-install   # 📦 extract installer
sudo /tmp/awscli-install/aws/install             # ⬇️ install AWS CLI v2
rm -rf /tmp/awscliv2.zip /tmp/awscli-install      # 🧹 clean up
```

<details>
<summary>🛠️ Troubleshoot this step</summary>

**Error seen:** `curl: (22) The requested URL returned error: 403` or a file named `awscliv2.zip` that is actually an HTML error page (`unzip` reports `End-of-central-directory signature not found`).

**Recovery:** Delete the corrupt file with `rm /tmp/awscliv2.zip`, then visit the official URL in a browser to confirm the correct download link before retrying.

📚 Docs: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

</details>

### 🔑 Step 2: Configure AWS credentials and verify both tools

Configure the AWS CLI with the credentials provided in your Al Nafi lab session, then confirm Terraform and the AWS CLI can both communicate with AWS.

```bash
# 🔑 Configure AWS credentials interactively
aws configure
# When prompted, enter: AWS Access Key ID, AWS Secret Access Key, default region (us-east-1), output format (json)

# ✅ Verify Terraform
terraform version

# ✅ Verify AWS CLI and credential validity
aws sts get-caller-identity
```

> 💡 You should see a Terraform version string and a JSON object containing your AWS Account, UserId, and Arn. If `aws sts get-caller-identity` returns an `InvalidClientTokenId` or `AuthFailure` error, your credentials are incorrect — re-run `aws configure` with the values from your lab portal.

<details>
<summary>🛠️ Troubleshoot this step</summary>

**Error seen:** `An error occurred (InvalidClientTokenId) when calling the GetCallerIdentity operation: The security token included in the request is invalid.`

**Recovery:** Run `cat ~/.aws/credentials` to inspect what was saved. Delete the file with `rm ~/.aws/credentials` and re-run `aws configure` with the exact key values from your Al Nafi lab dashboard.

📚 Docs: https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html

</details>

> 🟢 **Sign-off:** Terraform and AWS CLI installed, credentials configured, and both verified against AWS.

---

## 🧩 Task 2: Design and Build a Reusable EC2 Module

![Terraform](https://img.shields.io/badge/Terraform-844FBA?style=flat-square&logo=terraform&logoColor=white)
![EC2](https://img.shields.io/badge/Amazon%20EC2-FF9900?style=flat-square&logo=amazonec2&logoColor=white)
![Modules](https://img.shields.io/badge/Terraform%20Modules-844FBA?style=flat-square&logo=terraform&logoColor=white)

> 📝 **Problem statement:** Design and implement a Terraform module located at `~/tf-modular-lab/modules/ec2` that encapsulates all logic required to provision a single EC2 instance. The module must expose a variable interface expressive enough that a caller can produce meaningfully different infrastructure — different instance sizes, storage configurations, environment labels, and startup behavior — purely by changing input values, with **no edits to the module source itself**.

### 🗂️ Required Module Structure

| File | Contents |
|---|---|
| `variables.tf` | All inputs declared with types, descriptions, and sensible defaults |
| `main.tf` | All resource definitions |
| `outputs.tf` | At minimum: instance ID, public IP, private IP, and the IDs of any security groups the module creates |

### ✅ Design Requirements

- [ ] The module creates its **own security group** when the caller does not supply one
- [ ] A consistent set of resource **tags** is applied, derived from input variables
- [ ] **All root EBS volumes are encrypted**

#### ✅ Acceptance Criteria

- [ ] `terraform init` followed by `terraform validate` inside the module directory exits with code `0` and prints `"Success! The configuration is valid."` — no warnings, no errors
- [ ] Calling the module twice in the same root configuration with different values for `instance_type`, `root_volume_size`, and `environment`, then running `terraform plan`, produces a plan showing **two distinct EC2 instances** whose planned attributes reflect the differing variable values (confirmed by reading the plan output)

```bash
# TODO: author variables.tf, main.tf, and outputs.tf under ~/tf-modular-lab/modules/ec2
# implementing the structure and requirements above
cd ~/tf-modular-lab/modules/ec2
terraform init
terraform validate
```

> 🟢 **Sign-off:** Reusable `ec2` module validated with a clean variable interface and no hard-coded infrastructure.

---

## 🏗️ Task 3: Compose Environment Configurations Using the Module

![Terraform](https://img.shields.io/badge/Terraform-844FBA?style=flat-square&logo=terraform&logoColor=white)
![CloudWatch](https://img.shields.io/badge/Amazon%20CloudWatch-FF4F8B?style=flat-square&logo=amazoncloudwatch&logoColor=white)
![EBS](https://img.shields.io/badge/Amazon%20EBS-FF9900?style=flat-square&logo=amazonaws&logoColor=white)

> 📝 **Problem statement:** Design and implement three separate Terraform root configurations — one each for **dev**, **test**, and **prod** — located at `~/tf-modular-lab/environments/dev`, `~/tf-modular-lab/environments/test`, and `~/tf-modular-lab/environments/prod`. Each root configuration must call your `modules/ec2` module one or more times using only **relative source paths**.

### 🌍 Per-Environment Differences

| Environment | Requirements |
|---|---|
| 🧪 `dev` | Smallest and cheapest instance sizes; auto-shutdown tags |
| 🧫 `test` | At least **2 instances** — a web tier and an application tier |
| 🏭 `prod` | At least **3 instances**; detailed CloudWatch monitoring enabled on all of them; larger root volumes; backup-related tags |

- [ ] Each environment directory contains its own `outputs.tf` surfacing a structured summary of every instance it creates, including instance IDs and IP addresses
- [ ] **No environment configuration duplicates resource logic that belongs in the module** — any `aws_instance` block written directly in an environment file must instead be moved into the module

#### ✅ Acceptance Criteria

- [ ] `terraform init` and `terraform plan` inside each of the three environment directories complete without errors
- [ ] The plan output for `prod` shows at least **three** planned `aws_instance` resources, each with `monitoring = true` and a `root_block_device` volume size **≥ 20 GB**, confirmed via:
  ```bash
  terraform plan -out=prod.tfplan && terraform show -json prod.tfplan | grep -E '"monitoring"|"volume_size"'
  ```
- [ ] `terraform output` in each environment directory, after applying, displays a structured map containing the instance ID and at least one IP address for every instance that environment manages — **zero null values** for any successfully created instance

```bash
# TODO: author dev/test/prod root configurations under ~/tf-modular-lab/environments/
# each calling ../../modules/ec2 with environment-appropriate variable values
cd ~/tf-modular-lab/environments/prod
terraform init
terraform plan -out=prod.tfplan
terraform show -json prod.tfplan | grep -E '"monitoring"|"volume_size"'
```

> 🟢 **Sign-off:** Dev, test, and prod environments composed entirely from module calls, with plans that verifiably differ by tier.

---

## 📦 Expected Outcomes

- ✅ A fully validated, reusable Terraform module that provisions EC2 instances with **zero resource logic duplicated** across the three environment configurations that consume it
- 🌍 Three independently plannable environment configurations whose plans demonstrably differ in instance count, size, monitoring settings, and tags — driven entirely by module variable inputs

---

## 🧠 Key Concepts

| Concept | Description |
|---|---|
| 🧩 Module Abstraction | Encapsulating resource logic behind `variables.tf` / `main.tf` / `outputs.tf` so callers configure behavior without editing source |
| 🔁 Reusability | The same module, called with different inputs, produces meaningfully different infrastructure |
| 🌍 Environment Composition | Root configurations (dev/test/prod) consume a shared module rather than duplicating resource blocks |
| 🔐 Secure Defaults | Encrypting root EBS volumes and auto-creating a security group when none is supplied |
| ✅ Plan-Based Validation | Inspecting `terraform plan -out` / `terraform show -json` output to confirm environment-specific attributes before applying |

---

## ✅ Conclusion

This lab required separating the concern of **how** infrastructure is built (the module) from the concern of **what** infrastructure each environment needs (the root configurations). That separation is the foundation of maintainable infrastructure-as-code: when AWS changes an API or your organization adopts a new tagging standard, you update one module and every environment inherits the change automatically.

Carry this principle forward by treating any resource block you find yourself copying between configurations as a signal that a module boundary is missing.

---

<div align="center">

![Al Nafi](https://img.shields.io/badge/Al%20Nafi-Cybersecurity%20Training-blueviolet?style=for-the-badge)

</div>
