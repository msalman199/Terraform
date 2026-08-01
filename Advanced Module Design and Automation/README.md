<div align="center">

# 🧩 Advanced Terraform Module Design and Automated Testing

### Building a Reusable kind-Kubernetes Module, Proven by Terratest and a Makefile CI Pipeline

![Terraform](https://img.shields.io/badge/Terraform-844FBA?style=for-the-badge&logo=terraform&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![kind](https://img.shields.io/badge/kind-2496ED?style=for-the-badge&logo=kubernetes&logoColor=white)
![Go](https://img.shields.io/badge/Go-00ADD8?style=for-the-badge&logo=go&logoColor=white)
![Terratest](https://img.shields.io/badge/Terratest-00ADD8?style=for-the-badge&logo=go&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Make](https://img.shields.io/badge/Make-A42E2B?style=for-the-badge&logo=gnu&logoColor=white)
![Bash](https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)

</div>

---

## 📋 Table of Contents

- [🎯 Objectives](#-objectives)
- [📌 Prerequisites](#-prerequisites)
- [🖥️ Lab Environment](#️-lab-environment)
- [🧰 Task 1: Install and Verify the Full Toolchain](#-task-1-install-and-verify-the-full-toolchain)
- [🧱 Task 2: Design and Implement the Kubernetes Cluster Terraform Module](#-task-2-design-and-implement-the-kubernetes-cluster-terraform-module)
- [🧪 Task 3: Implement Automated Testing with Terratest and a CI Pipeline Makefile](#-task-3-implement-automated-testing-with-terratest-and-a-ci-pipeline-makefile)
- [🏆 Expected Outcomes](#-expected-outcomes)
- [🧠 Key Concepts](#-key-concepts)
- [🏁 Conclusion](#-conclusion)

---

## 🎯 Objectives

| # | Objective |
|---|-----------|
| 1 | 🧩 Design a production-grade, reusable Terraform module that provisions a local Kubernetes cluster using **kind** (Kubernetes in Docker) |
| 2 | 🧪 Implement automated infrastructure tests using **Terratest**, a Go-based testing framework for Terraform |
| 3 | ⚙️ Build a CI/CD-ready **Makefile** pipeline that validates, plans, applies, tests, and destroys infrastructure in a single command chain |

---

## 📌 Prerequisites

| Requirement | Details |
|-------------|---------|
| 💻 Linux CLI | Comfort with Linux command-line operations including file permissions, environment variables, and shell scripting |
| ☸️ Kubernetes Concepts | Familiarity with nodes, pods, deployments, services, and namespaces |
| 🐹 Go Syntax | Basic understanding of Go syntax sufficient to read and write test functions |

---

## 🖥️ Lab Environment

> 💡 You will work on a dedicated AWS EC2 Ubuntu instance provided by Al Nafi. The instance has a **base Ubuntu installation**; you will install all required tools in Task 1.

---

## 🧰 Task 1: Install and Verify the Full Toolchain

> **Step 1:** Install system dependencies, Terraform, kind, kubectl, and Go. Install every tool the lab requires and confirm each binary is reachable on your PATH. The tools are: **Terraform** (infrastructure-as-code CLI), **kind** (runs Kubernetes clusters inside Docker containers), **kubectl** (Kubernetes command-line client), **Docker** (container runtime required by kind), and **Go** (language used by Terratest).

### 📦 Install System Packages

```bash
sudo apt-get update -y
sudo apt-get install -y curl wget unzip git jq tree make
```

### 🐳 Install Docker

```bash
curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker "$USER"
newgrp docker
docker version
```

> 📖 Official Docker install guide: https://docs.docker.com/engine/install/ubuntu/

<details>
<summary>🛠️ Troubleshoot this step</summary>

**Error seen:** `permission denied while trying to connect to the Docker daemon socket`

**Recovery:** Run `groups` and confirm `docker` appears; if not, log out and back in, then re-run `newgrp docker`.
📖 Docs: https://docs.docker.com/engine/install/linux-postinstall/
</details>

### 🌍 Install Terraform 1.6.6

```bash
wget -fsSL https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_linux_amd64.zip
unzip terraform_1.6.6_linux_amd64.zip
sudo mv terraform /usr/local/bin/
rm terraform_1.6.6_linux_amd64.zip
terraform version
```

> 📖 Official Terraform install guide: https://developer.hashicorp.com/terraform/install

<details>
<summary>🛠️ Troubleshoot this step</summary>

**Error seen:** `terraform: command not found` after moving the binary

**Recovery:** Run `echo $PATH` and confirm `/usr/local/bin` is listed; if not, run `export PATH=$PATH:/usr/local/bin` and add that line to `~/.bashrc`.
📖 Docs: https://developer.hashicorp.com/terraform/install
</details>

### ⚓ Install kubectl (Stable Release)

```bash
KUBECTL_VERSION=$(curl -fsSL https://dl.k8s.io/release/stable.txt)
curl -fsSL "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" -o kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl
kubectl version --client
```

> 📖 Official kubectl install guide: https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/

### 🐋 Install kind v0.20.0

```bash
curl -fsSL https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64 -o kind
chmod +x kind
sudo mv kind /usr/local/bin/kind
kind version
```

> 📖 Official kind install guide: https://kind.sigs.k8s.io/docs/user/quick-start/#installation

<details>
<summary>🛠️ Troubleshoot this step</summary>

**Error seen:** `kind: /lib/x86_64-linux-gnu/libc.so.6: version GLIBC_2.32 not found`

**Recovery:** Download the latest kind release from https://github.com/kubernetes-sigs/kind/releases and replace the binary.
📖 Docs: https://kind.sigs.k8s.io/docs/user/quick-start/
</details>

### 🐹 Install Go 1.21.5

```bash
wget -fsSL https://go.dev/dl/go1.21.5.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go1.21.5.linux-amd64.tar.gz
rm go1.21.5.linux-amd64.tar.gz

printf 'export PATH=$PATH:/usr/local/go/bin\nexport GOPATH=$HOME/go\nexport PATH=$PATH:$GOPATH/bin\n' >> ~/.bashrc
source ~/.bashrc
go version
```

> 📖 Official Go install guide: https://go.dev/doc/install

<details>
<summary>🛠️ Troubleshoot this step</summary>

**Error seen:** `go: command not found` immediately after sourcing `.bashrc`

**Recovery:** Run `export PATH=$PATH:/usr/local/go/bin` directly in the current shell, then verify with `which go`.
📖 Docs: https://go.dev/doc/install
</details>

### ✅ Step 2: Confirm the Complete Toolchain Is Operational

Run the following verification block. Every command must exit without error and print a version string. If any command fails, return to Step 1 and reinstall that tool before continuing.

```bash
echo "=== Toolchain Verification ==="
terraform version
kubectl version --client --output=json | jq -r '.clientVersion.gitVersion'
kind version
docker info --format '{{.ServerVersion}}'
go version
echo "=== All tools verified ==="
```

> ✅ **Confirmation:** You should see **five distinct version strings** printed with no error messages. The Docker line prints the server daemon version, not a CLI version, so Docker must be running for it to succeed.

---

## 🧱 Task 2: Design and Implement the Kubernetes Cluster Terraform Module

> ⚠️ No starter templates are provided for this task. Design and implement a self-contained, reusable Terraform module **entirely your own work**, located at `~/tf-k8s-lab/modules/k8s-cluster/`, that provisions a local Kubernetes cluster using kind.

### 📜 Problem Statement

The module must accept inputs for:

| Input | Description |
|-------|--------------|
| 🏷️ Cluster name | Name of the kind cluster to create |
| 🔢 Worker node count | Between 1 and 10 |
| 🖼️ Kubernetes node image | The kind node image to use |
| 🌐 NGINX Ingress Controller | Optional |
| 📊 metrics-server | Optional monitoring component |

The module must produce outputs for:

| Output | Description |
|--------|--------------|
| 🏷️ Cluster name | The resolved cluster name |
| 🔗 kubectl context string | Context to target this cluster |
| 📄 kubeconfig file path | Path to the generated kubeconfig |
| 📦 Cluster metadata object | Structured object containing all cluster metadata |

**Design constraints:**
- 🚫 The module must use **only** the `hashicorp/null` and `hashicorp/local` providers — no cloud provider credentials are required
- ⚙️ All cluster lifecycle operations (create, destroy) must be driven by shell scripts invoked through `null_resource` provisioners
- 📝 The kind cluster configuration must be generated from a Terraform `templatefile()` call rather than hardcoded inline

### ✅ Acceptance Criterion 1

Running `terraform apply` in `~/tf-k8s-lab/examples/basic-cluster/` (a caller that references your module) must complete without error, and `kind get clusters` must list the cluster name that was passed as input. Running `terraform destroy` immediately afterward must remove the cluster so that `kind get clusters` no longer lists it.

### ✅ Acceptance Criterion 2

Passing an empty string as `cluster_name` or a value greater than 10 for `node_count` must cause `terraform plan` to fail with a validation error message — the plan must not reach the apply phase. Confirm this by running `terraform plan` with each invalid value and observing a non-zero exit code.

| ✔️ | Criterion |
|---|-----------|
| ☐ | `terraform apply` in `examples/basic-cluster/` succeeds; `kind get clusters` lists the created cluster |
| ☐ | `terraform destroy` removes the cluster; `kind get clusters` no longer lists it |
| ☐ | An empty `cluster_name` fails `terraform plan` with a validation error (non-zero exit code) |
| ☐ | A `node_count` greater than 10 fails `terraform plan` with a validation error (non-zero exit code) |

> 🎓 **TODO:** Write your `variable "node_count"` validation block before writing any of the `null_resource` provisioner scripts — get the contract failing correctly first, then build the behavior that satisfies it.

---

## 🧪 Task 3: Implement Automated Testing with Terratest and a CI Pipeline Makefile

> ⚠️ No starter templates are provided for this task. Design and implement the test suite and Makefile **entirely your own work**.

### 📜 Problem Statement

Design and implement a Go-based automated test suite inside `~/tf-k8s-lab/test/` using the **Terratest** library. The suite must contain at minimum three test functions:

| Test Function | Behavior Under Test |
|----------------|------------------------|
| 1️⃣ Single-worker cluster | Provisions a single-worker cluster, waits for all nodes to reach `Ready` state, deploys an `nginx` pod, and asserts the pod reaches `Running` phase |
| 2️⃣ Ingress-enabled cluster | Provisions a cluster with the ingress flag enabled and asserts the `ingress-nginx-controller` deployment reaches `Available` state within **five minutes** |
| 3️⃣ Invalid-variable rejection | Passes an invalid variable to the module and asserts that `terraform plan` returns an error **without creating any infrastructure** |

**Test design requirements:**
- 🎲 Each test must generate a **unique cluster name** using a timestamp or random suffix so parallel test runs do not collide
- 🧹 Each test must call `defer terraform.Destroy` as its **first action** after `InitAndApply`, so clusters are always cleaned up even when assertions fail

### ⚙️ Makefile Pipeline

Design a `Makefile` at `~/tf-k8s-lab/Makefile` that exposes the following targets:

| Target | Behavior |
|--------|----------|
| 🧹 `fmt` | Runs `go fmt` and `terraform fmt -recursive` |
| ✅ `validate` | Runs `terraform validate` on the module and example |
| ⚡ `test-unit` | Runs only the validation-failure test with a **10-minute timeout** |
| 🧪 `test-integration` | Runs the cluster-creation and ingress tests with a **45-minute timeout** |
| 🔁 `ci` | Runs `fmt`, `validate`, `test-unit`, and `test-integration` in sequence, **stopping on first failure** |

### ✅ Acceptance Criterion 1

Running `make test-unit` must complete in under 10 minutes, print `PASS` for the validation test, and leave **zero kind clusters running** afterward (confirmed with `kind get clusters` returning empty output).

### ✅ Acceptance Criterion 2

Running `make test-integration` must complete in under 45 minutes, print `PASS` for both the basic cluster test and the ingress test, and leave **zero kind clusters running** afterward. The ingress test must confirm the controller pod count is greater than zero by asserting on the list of pods in the `ingress-nginx` namespace.

| ✔️ | Criterion |
|---|-----------|
| ☐ | `make test-unit` completes in under 10 minutes and prints `PASS` for the validation test |
| ☐ | `make test-unit` leaves zero kind clusters running (`kind get clusters` is empty) |
| ☐ | `make test-integration` completes in under 45 minutes and prints `PASS` for both tests |
| ☐ | `make test-integration` leaves zero kind clusters running afterward |
| ☐ | The ingress test asserts `ingress-nginx` namespace pod count > 0 |

---

## 🏆 Expected Outcomes

- 🧩 A fully functional Terraform module with input validation, templated configuration, lifecycle scripts, and structured outputs that can be consumed by any caller without modification to the module source
- 🧪 A Terratest suite and Makefile pipeline that can be executed in a single `make ci` command and produces a clear pass/fail result for every infrastructure behavior the module is expected to provide

---

## 🧠 Key Concepts

| Concept | Tool / Technique | Purpose |
|---------|-------------------|---------|
| 🧩 Module Contract | `variables.tf` + `outputs.tf` | Defines the module's interface before implementation — the "contract" callers rely on |
| ✅ Input Validation | `variable` blocks with `validation {}` | Rejects invalid input at `plan` time instead of failing mid-`apply` |
| 📝 Templated Configuration | `templatefile()` | Generates the kind cluster YAML from variables instead of hardcoding it |
| ⚙️ Lifecycle Scripting | `null_resource` + local-exec provisioners | Drives cluster create/destroy via shell scripts under Terraform's lifecycle |
| 🧪 Infrastructure Testing | Terratest (`InitAndApply`, `defer terraform.Destroy`) | Proves module behavior automatically instead of manual verification |
| 🔁 Pipeline Chaining | Makefile targets (`fmt` → `validate` → `test-unit` → `test-integration`) | Wraps the whole verification flow into one `make ci` command, stopping on first failure |
| 🧹 Test Isolation | Unique cluster names + `defer` cleanup | Prevents parallel test runs from colliding and guarantees clusters are destroyed even on failure |

---

## 🏁 Conclusion

This lab required you to move beyond guided Terraform usage and take ownership of module architecture, test design, and pipeline automation simultaneously. The separation between the module, the example caller, and the test suite mirrors how production infrastructure teams version and validate shared modules before publishing them. Mastering this pattern — write the contract first (variables and outputs), implement the behavior, then prove it with automated tests — is the foundation of reliable infrastructure engineering at scale.

---

<div align="center">

![Al Nafi](https://img.shields.io/badge/Al%20Nafi-Cybersecurity%20Training-blueviolet?style=for-the-badge)

</div>
