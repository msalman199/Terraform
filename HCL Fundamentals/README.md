<div align="center">

# 🧬 HCL Fundamentals

### Mastering Terraform's Expression Language — Variables, Locals, and Meta-Arguments

![Terraform](https://img.shields.io/badge/Terraform-844FBA?style=for-the-badge&logo=terraform&logoColor=white)
![HCL](https://img.shields.io/badge/HCL-5C4EE5?style=for-the-badge&logo=terraform&logoColor=white)
![Local%20Provider](https://img.shields.io/badge/Local%20Provider-2C2C2C?style=for-the-badge&logo=terraform&logoColor=white)
![JSON](https://img.shields.io/badge/JSON-000000?style=for-the-badge&logo=json&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)

**Difficulty:** 🟡 Intermediate &nbsp;|&nbsp; **Duration:** ⏱️ 90–120 minutes &nbsp;|&nbsp; **Track:** ☁️ Cloud DevOps

</div>

---

## 📑 Table of Contents

- [🎯 Objectives](#-objectives)
- [📋 Prerequisites](#-prerequisites)
- [🖥️ Lab Environment](#️-lab-environment)
- [🧰 Task 1: Install and Verify the Terraform Toolchain](#-task-1-install-and-verify-the-terraform-toolchain)
- [🧮 Task 2: Design a Variable-Driven Configuration with Locals and Outputs](#-task-2-design-a-variable-driven-configuration-with-locals-and-outputs)
- [🏗️ Task 3: Build a Multi-Resource Configuration Using for_each, count, and Dynamic Patterns](#️-task-3-build-a-multi-resource-configuration-using-for_each-count-and-dynamic-patterns)
- [📦 Expected Outcomes](#-expected-outcomes)
- [🧠 Key Concepts](#-key-concepts)
- [✅ Conclusion](#-conclusion)

---

## 🎯 Objectives

| # | Objective |
|---|-----------|
| 1 | 🎛️ Design and implement a complete HCL configuration system using variables, locals, and outputs with validation constraints |
| 2 | 🔁 Build a multi-resource configuration that uses `for_each`, `count`, and dynamic block patterns to eliminate repetition |
| 3 | 📦 Produce a deployable Terraform project that passes `terraform validate` and generates correct output artifacts from a single `terraform apply` |

---

## 📋 Prerequisites

| Requirement | Details |
|---|---|
| 🐧 Linux CLI | Comfort with file navigation, text editing, and reading command output |
| 🧩 Data Structures | Familiarity with key-value structures and basic programming concepts (conditionals, loops) |

---

## 🖥️ Lab Environment

> 💡 **Note:** You will work on a dedicated AWS EC2 Ubuntu instance provided by Al Nafi. The instance has a base Ubuntu installation — you will install all required tools in Task 1.

![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?style=flat-square&logo=ubuntu&logoColor=white)
![EC2](https://img.shields.io/badge/Amazon%20EC2-FF9900?style=flat-square&logo=amazonec2&logoColor=white)

---

## 🧰 Task 1: Install and Verify the Terraform Toolchain

![Terraform](https://img.shields.io/badge/Terraform-844FBA?style=flat-square&logo=terraform&logoColor=white)
![APT](https://img.shields.io/badge/APT-A81D33?style=flat-square&logo=debian&logoColor=white)
![GPG](https://img.shields.io/badge/GPG-role--auth-blue?style=flat-square)

> 📝 **Problem statement:** Your Ubuntu instance has no tooling. You must install Terraform from the official HashiCorp APT repository, confirm the binary is reachable on your `PATH`, and confirm the HCL formatter and validator both execute without error before writing a single line of configuration.

### 📥 Requirement 1 — Install Terraform via the HashiCorp APT repository

Install Terraform using the HashiCorp signed APT repository and verify the installed version is **1.5.0 or higher**. The command must exit with code `0` and print a version string — not an error page or a "command not found" message.

```bash
sudo apt-get update -y                                              # 🔄 refresh package index
sudo apt-get install -y gnupg software-properties-common curl       # 📦 install prerequisites

curl -fsSL https://apt.releases.hashicorp.com/gpg \
  | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
# 🔐 imports and de-armors HashiCorp's signing key

printf 'deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com %s main\n' \
  "$(lsb_release -cs)" \
  | sudo tee /etc/apt/sources.list.d/hashicorp.list
# 📡 registers the official HashiCorp APT repository

sudo apt-get update -y        # 🔄 pick up the new repo
sudo apt-get install -y terraform   # ⬇️ install Terraform CLI

terraform version   # ✅ confirm version >= 1.5.0, exit code 0
```

📚 Official installation guide (consult if the URL above changes): https://developer.hashicorp.com/terraform/install

<details>
<summary>🛠️ Troubleshoot this step</summary>

You may see `E: Malformed entry 1 in list file /etc/apt/sources.list.d/hashicorp.list` if the `printf` command wrote a literal backslash into the file.

- Inspect the file with `cat /etc/apt/sources.list.d/hashicorp.list` — it must be a single unbroken line.
- If it isn't, delete it with `sudo rm /etc/apt/sources.list.d/hashicorp.list` and re-run the `printf` command.
- 📚 Official reference: https://developer.hashicorp.com/terraform/install

</details>

### 📂 Requirement 2 — Initialize the working directory

Create a working directory at `~/hcl-lab` containing an empty file named `main.tf`, run `terraform init` inside that directory, and confirm the command prints `"Terraform has been successfully initialized"` before proceeding to Task 2.

```bash
mkdir -p ~/hcl-lab && cd ~/hcl-lab   # 📂 create + enter project directory
touch main.tf                        # 📄 empty placeholder config file
terraform init                       # ⚙️ initialize the working directory
```

#### ✅ Acceptance Criteria

- [ ] `terraform version` prints a version string of **1.5.0 or higher** and exits with code `0`
- [ ] `terraform init` inside `~/hcl-lab` exits with code `0` and prints the initialization success message

> 🟢 **Sign-off:** Terraform toolchain installed, verified, and working directory initialized.

---

## 🧮 Task 2: Design a Variable-Driven Configuration with Locals and Outputs

![Terraform](https://img.shields.io/badge/Terraform-844FBA?style=flat-square&logo=terraform&logoColor=white)
![HCL](https://img.shields.io/badge/HCL-5C4EE5?style=flat-square&logo=terraform&logoColor=white)
![Local%20Provider](https://img.shields.io/badge/Local%20Provider-2C2C2C?style=flat-square&logo=terraform&logoColor=white)

> 📝 **Problem statement:** Design and implement a Terraform configuration that models a fictional multi-environment infrastructure project using **only the `local` provider** (no cloud credentials required). All environment-specific values must come through declared input variables, all computed values must be derived exclusively through `locals` blocks, and a structured summary must be exposed through `output` blocks. No hard-coded environment names, counts, or paths may appear outside of variable default values.

> 💡 The `local` provider (`hashicorp/local`, version `~> 2.4`) writes files to disk — use `local_file` resources to produce output artifacts inspectable after `terraform apply`.

### 🎛️ Requirement 1 — Input variables

Declare input variables that together describe:

| Variable | Type | Description |
|---|---|---|
| Project name | `string` | Name of the fictional project |
| Target environment | `string` | Constrained via `validation` to exactly `development`, `staging`, or `production` |
| Services map | `map(object)` | Maps service names to objects containing `port` and `replica_count` |
| Deployment regions | `list(string)` | At least two deployment regions |

- [ ] Every variable includes a `description` and a `default` so the configuration applies **without** a `terraform.tfvars` file

### 🧠 Requirement 2 — Locals and outputs

Implement a `locals` block that derives, at minimum:

| Derived value | Behavior |
|---|---|
| 🏷️ Common tags | Merged map from project name, environment, and a formatted timestamp |
| 🔗 Flattened service-region pairs | One entry per service × region combination, iterable for later use |
| 🔢 Conditional replica scaling | Replica count × 3 when environment is `production`; unchanged otherwise |

Expose as **named outputs**:

- The flattened service-region structure
- The effective replica counts per service
- The merged tag map
- [ ] At least one output explicitly marked `sensitive = false`
- [ ] At least one output uses a `for` expression in its `value` field

#### ✅ Acceptance Criteria

- [ ] `terraform validate` exits with code `0` and prints `"Success! The configuration is valid."`
- [ ] `terraform apply -auto-approve` exits with code `0`
- [ ] `terraform output -json` prints a JSON object containing all declared outputs with non-null values

```bash
# TODO: author variables.tf, locals.tf, and outputs.tf implementing the requirements above
terraform validate
terraform apply -auto-approve
terraform output -json
```

> 🟢 **Sign-off:** Variable-driven configuration validated and applied with structured JSON outputs.

---

## 🏗️ Task 3: Build a Multi-Resource Configuration Using `for_each`, `count`, and Dynamic Patterns

![Terraform](https://img.shields.io/badge/Terraform-844FBA?style=flat-square&logo=terraform&logoColor=white)
![JSON](https://img.shields.io/badge/JSON-000000?style=flat-square&logo=json&logoColor=white)
![Templates](https://img.shields.io/badge/templatefile()-5C4EE5?style=flat-square&logo=terraform&logoColor=white)

> 📝 **Problem statement:** Extend Task 2 into a complete project that generates structured file artifacts on disk — one configuration file per service-region pair, one deployment script per region, and one consolidated monitoring manifest — using `for_each` and `count` to eliminate all manual repetition. Demonstrate a dynamic content pattern by constructing the monitoring manifest's scrape targets **programmatically** from the services map rather than listing them by hand.

> 💡 A "deployment script" here is a `local_file` resource whose content comes from a `templatefile()` call referencing a `.tpl` file you author — it doesn't need to be executable, but must interpolate region-specific and service-specific values from variables and locals.

### 🔁 Requirement 1 — `for_each` and `count` artifacts

| Pattern | Output | Path |
|---|---|---|
| `for_each` over flattened service-region pairs | JSON file per combination: service name, region, port, effective replica count | `output/<region>/<service>.json` |
| `count` over the regions list | One deployment script per region, rendered via `templatefile()`, listing that region's service names | `output/scripts/deploy-<region>.sh` |

- [ ] No resource block references a specific service name or region name as a string literal

### 📊 Requirement 2 — Dynamic monitoring manifest

Create a single `local_file` resource at `output/monitoring/scrape-config.json` whose content is built using `jsonencode()` and a `for` expression iterating over the services map to produce one scrape target object per service, containing:

- Service name
- Port
- Health-check path (add a `health_check` field to the service variable object if not already present)
- A list of fully qualified target addresses in the format `<service>.<region>.internal` for every region

- [ ] Changing the `services` variable default and re-applying produces a different file **without any change to the resource block itself**

#### ✅ Acceptance Criteria

- [ ] After `terraform apply -auto-approve`, `find output/ -type f | wc -l` equals **(service-region pairs) + (number of regions) + 2** (monitoring file + monitoring directory placeholder)
- [ ] `terraform plan` after a successful apply prints `"No changes. Your infrastructure matches the configuration."` (idempotency confirmed)

```bash
# TODO: author main.tf resources using for_each/count plus the .tpl template file
terraform apply -auto-approve
find output/ -type f | wc -l
terraform plan
```

> 🟢 **Sign-off:** Multi-resource project generates all artifacts idempotently from a single source of truth.

---

## 📦 Expected Outcomes

- ✅ A fully validated Terraform project in `~/hcl-lab` that applies cleanly from scratch, generates all file artifacts in the correct directory structure, and produces structured JSON output from `terraform output -json`
- 🧠 Demonstrated mastery of HCL's type system, expression language, and meta-arguments — adding a new service or region to a variable default automatically propagates through every resource and output without any other edits

---

## 🧠 Key Concepts

| Concept | Description |
|---|---|
| 🎛️ Variables → Locals → Outputs pipeline | Every computed value flows through this pipeline rather than being hard-coded |
| 🔁 `for_each` / `count` | Meta-arguments that eliminate repeated resource blocks by iterating over collections |
| 🧬 Dynamic content generation | `templatefile()` and `jsonencode()` build artifact content programmatically from variables and locals |
| ✅ Validation constraints | `validation` blocks enforce allowed values (e.g., environment name) at plan time |
| 🗂️ Idempotency | A correctly written configuration reports "No changes" on a repeated `terraform plan` |

---

## ✅ Conclusion

This lab required reasoning about HCL as a **typed expression language** rather than a templating system — forcing every computed value through the variable → locals → output pipeline, and every repeated resource through `for_each` or `count`. Using only the `local` provider removed cloud-credential complexity so the focus stayed entirely on HCL semantics.

The patterns applied here — flattening nested structures for `for_each`, conditional scaling through locals, and programmatic content generation with `templatefile()` and `jsonencode()` — transfer directly to real provider resources such as `aws_instance`, `azurerm_virtual_machine`, and `google_compute_instance`.

---

<div align="center">

![Al Nafi](https://img.shields.io/badge/Al%20Nafi-Cybersecurity%20Training-blueviolet?style=for-the-badge)

</div>
