<div align="center">

# 🧪 Testing and Quality Assurance with Terraform

### Building Automated QA Pipelines for Infrastructure as Code

![Terraform](https://img.shields.io/badge/Terraform-844FBA?style=for-the-badge&logo=terraform&logoColor=white)
![tflint](https://img.shields.io/badge/tflint-1F1F1F?style=for-the-badge&logo=terraform&logoColor=7B42BC)
![tfsec](https://img.shields.io/badge/tfsec-00ADD8?style=for-the-badge&logo=security&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Bash](https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Pre--commit](https://img.shields.io/badge/pre--commit-FAB040?style=for-the-badge&logo=pre-commit&logoColor=black)
![DevSecOps](https://img.shields.io/badge/DevSecOps-000000?style=for-the-badge&logo=shieldsdotio&logoColor=white)

</div>

---

## 📋 Table of Contents

- [🎯 Lab Objectives](#-lab-objectives)
- [📌 Prerequisites](#-prerequisites)
- [🖥️ Lab Environment](#️-lab-environment)
- [🧩 Task 1: Install tflint and Run Configuration Analysis](#-task-1-install-tflint-and-run-configuration-analysis)
- [🔒 Task 2: Use tfsec to Check for Security Issues](#-task-2-use-tfsec-to-check-for-security-issues)
- [✅ Task 3: Run terraform validate to Ensure Syntax Correctness](#-task-3-run-terraform-validate-to-ensure-syntax-correctness)
- [🚦 Task 4: Implement Quality Assurance Workflow](#-task-4-implement-quality-assurance-workflow)
- [🛠️ Troubleshooting Common Issues](#️-troubleshooting-common-issues)
- [🧠 Key Concepts](#-key-concepts)
- [🏁 Lab Summary](#-lab-summary)

---

## 🎯 Lab Objectives

By the end of this lab, you will be able to:

| # | Objective |
|---|-----------|
| 1 | 🧹 Install and configure **tflint** to analyze Terraform configurations for best practices and errors |
| 2 | 🔐 Use **tfsec** to identify security vulnerabilities in Terraform code |
| 3 | ✅ Execute **terraform validate** to verify syntax correctness and configuration validity |
| 4 | 🚦 Implement a comprehensive quality assurance workflow for Infrastructure as Code |
| 5 | 🤖 Understand the importance of automated testing in infrastructure deployment |
| 6 | 🛡️ Apply security scanning techniques to prevent misconfigurations |

---

## 📌 Prerequisites

| Requirement | Details |
|-------------|---------|
| 📖 Terraform Syntax | Basic understanding of Terraform syntax and concepts |
| 💻 Linux CLI | Familiarity with Linux command-line operations |
| ☁️ IaC Principles | Knowledge of infrastructure as code principles |
| 🔒 Cloud Security | Understanding of basic security concepts in cloud infrastructure |
| 📦 Package Management | Experience with package management in Linux |

---

## 🖥️ Lab Environment

> 💡 Al Nafi provides Linux-based cloud machines for this lab. Simply click **Start Lab** to access your dedicated environment. The provided Linux machine is **bare metal with no pre-installed tools** — you will install all required tools during the lab exercises.

---

## 🧩 Task 1: Install tflint and Run Configuration Analysis

`tflint` is a Terraform linter that helps identify errors, warnings, and best practice violations in your Terraform configurations.

### 🔧 Subtask 1.1: Install tflint

**1️⃣ Update the system package manager:**
```bash
sudo apt update
```

**2️⃣ Install required dependencies:**
```bash
sudo apt install -y curl unzip wget
```

**3️⃣ Download and install tflint:**
```bash
# 📥 Download the latest tflint release
curl -s https://api.github.com/repos/terraform-linters/tflint/releases/latest | grep browser_download_url | grep linux_amd64.zip | cut -d '"' -f 4 | wget -qi -

# 📦 Extract the downloaded file
unzip tflint_linux_amd64.zip

# 🚚 Move tflint to system path
sudo mv tflint /usr/local/bin/

# ✅ Make it executable
sudo chmod +x /usr/local/bin/tflint

# 🔍 Verify installation
tflint --version
```

### 📝 Subtask 1.2: Create Sample Terraform Configuration

Create a sample Terraform configuration with intentional issues for testing purposes.

**1️⃣ Create a working directory:**
```bash
mkdir ~/terraform-qa-lab
cd ~/terraform-qa-lab
```

**2️⃣ Create a main Terraform file with some issues:**
```hcl
cat > main.tf << 'EOF'
# ⚠️ Sample Terraform configuration with intentional issues
terraform {
  required_version = ">= 0.12"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

# 🖥️ EC2 instance with issues
resource "aws_instance" "web_server" {
  ami           = "ami-0c02fb55956c7d316"  # ⚠️ Hardcoded AMI
  instance_type = "t2.micro"

  # 🔓 Security group allowing all traffic (security issue)
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  # ⚠️ Missing tags
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
  EOF
}

# 🔓 Security group with overly permissive rules
resource "aws_security_group" "web_sg" {
  name_prefix = "web-sg"
  description = "Security group for web server"

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # 🚨 Security issue: too permissive
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 🪣 S3 bucket with potential issues
resource "aws_s3_bucket" "data_bucket" {
  bucket = "my-data-bucket-12345"  # ⚠️ Hardcoded bucket name
}

# ⚠️ Unused variable (will trigger warning)
variable "unused_var" {
  description = "This variable is not used anywhere"
  type        = string
  default     = "unused"
}

# ⚠️ Output without description
output "instance_ip" {
  value = aws_instance.web_server.public_ip
}
EOF
```

> 🎓 **TODO:** After running the lab once, try adding your own intentional issue (e.g. an unencrypted EBS volume) and predict which tool — tflint or tfsec — will catch it.

### ⚙️ Subtask 1.3: Initialize tflint Configuration

**1️⃣ Create tflint configuration file:**
```hcl
cat > .tflint.hcl << 'EOF'
plugin "aws" {
  enabled = true
  version = "0.24.1"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

rule "terraform_deprecated_interpolation" {
  enabled = true
}

rule "terraform_unused_declarations" {
  enabled = true
}

rule "terraform_comment_syntax" {
  enabled = true
}

rule "terraform_documented_outputs" {
  enabled = true
}

rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_naming_convention" {
  enabled = true
  format  = "snake_case"
}
EOF
```

**2️⃣ Initialize tflint:**
```bash
tflint --init
```

### 🔍 Subtask 1.4: Run tflint Analysis

**1️⃣ Execute tflint on the configuration:**
```bash
tflint
```

**2️⃣ Run tflint with verbose output:**
```bash
tflint --format=compact
```

**3️⃣ Generate a detailed report:**
```bash
# 📊 Export findings as JSON, then pretty-print
tflint --format=json > tflint-report.json
cat tflint-report.json | python3 -m json.tool
```

---

## 🔒 Task 2: Use tfsec to Check for Security Issues

`tfsec` is a static analysis security scanner for Terraform code that identifies potential security issues.

### 📥 Subtask 2.1: Install tfsec

```bash
# 📥 Download and install tfsec
curl -s https://api.github.com/repos/aquasecurity/tfsec/releases/latest | grep browser_download_url | grep linux-amd64 | cut -d '"' -f 4 | wget -qi -

# ✅ Make it executable and move to system path
chmod +x tfsec-linux-amd64
sudo mv tfsec-linux-amd64 /usr/local/bin/tfsec

# 🔍 Verify installation
tfsec --version
```

### 🕵️ Subtask 2.2: Run Security Analysis with tfsec

**1️⃣ Execute basic tfsec scan:**
```bash
tfsec .
```

**2️⃣ Run tfsec with detailed output:**
```bash
tfsec --format=json . > tfsec-report.json
```

**3️⃣ View the JSON report:**
```bash
cat tfsec-report.json | python3 -m json.tool
```

**4️⃣ Generate HTML report:**
```bash
tfsec --format=html . > tfsec-report.html
```

**5️⃣ Run tfsec with specific severity levels:**
```bash
# 🚨 Show only high and critical severity issues
tfsec --minimum-severity=HIGH .
```

**6️⃣ Run tfsec with custom checks:**
```bash
# 🧪 Include all checks including experimental ones
tfsec --include-ignored --include-passed .
```

### ⚠️ Subtask 2.3: Create Additional Security Test Cases

**1️⃣ Create a file with more security issues:**
```hcl
cat > security-issues.tf << 'EOF'
# 🚨 Additional security issues for testing

# 🗄️ RDS instance without encryption
resource "aws_db_instance" "database" {
  identifier = "mydb"
  engine     = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"
  allocated_storage = 20

  db_name  = "myapp"
  username = "admin"
  password = "password123"  # 🚨 Hardcoded password - security issue

  # ⚠️ Missing encryption
  storage_encrypted = false

  # 🚨 Public access enabled - security issue
  publicly_accessible = true

  skip_final_snapshot = true
}

# 🪣 S3 bucket without proper security
resource "aws_s3_bucket" "insecure_bucket" {
  bucket = "insecure-bucket-example"
}

resource "aws_s3_bucket_public_access_block" "insecure_bucket_pab" {
  bucket = aws_s3_bucket.insecure_bucket.id

  # 🚨 Allowing public access - security issue
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# 🔑 IAM policy with overly broad permissions
resource "aws_iam_policy" "overly_permissive" {
  name        = "overly-permissive-policy"
  description = "Policy with too many permissions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "*"  # 🚨 Security issue: wildcard permissions
        Resource = "*"
      }
    ]
  })
}
EOF
```

**2️⃣ Run tfsec on the new file:**
```bash
tfsec --include-passed .
```

> 🎓 **TODO:** For each 🚨 flagged issue above, write the one-line remediated version of the resource block (e.g. `storage_encrypted = true`) in your own notes before moving to Task 3.

---

## ✅ Task 3: Run terraform validate to Ensure Syntax Correctness

### 📥 Subtask 3.1: Install Terraform

```bash
# 🔑 Add HashiCorp GPG key
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# 📦 Add HashiCorp repository
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# ⬇️ Update package list and install Terraform
sudo apt update
sudo apt install -y terraform

# 🔍 Verify installation
terraform version
```

### ⚙️ Subtask 3.2: Initialize Terraform Configuration

**1️⃣ Initialize the Terraform working directory:**
```bash
terraform init
```

**2️⃣ Verify initialization was successful:**
```bash
ls -la .terraform/
```

### 🔬 Subtask 3.3: Run Terraform Validation

**1️⃣ Execute basic validation:**
```bash
terraform validate
```

**2️⃣ Create a file with syntax errors for testing:**
```hcl
cat > syntax-errors.tf << 'EOF'
# 🚨 File with intentional syntax errors

resource "aws_instance" "broken_instance" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t2.micro"

  # 🚨 Missing closing quote - syntax error
  tags = {
    Name = "broken-instance
  }

  # 🚨 Invalid attribute name
  invalid_attribute = "this will cause an error"
}

# 🚨 Missing resource type
resource "broken_resource" {
  name = "test"
}

# 🚨 Invalid interpolation syntax
output "broken_output" {
  value = ${aws_instance.broken_instance.id}  # Old syntax
}
EOF
```

**3️⃣ Run validation on the configuration with errors:**
```bash
terraform validate
```

**4️⃣ Fix the syntax errors:**
```hcl
cat > syntax-errors.tf << 'EOF'
# ✅ Fixed syntax errors

resource "aws_instance" "fixed_instance" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t2.micro"

  # ✅ Fixed closing quote
  tags = {
    Name = "fixed-instance"
  }
}

# ✅ Fixed output with correct syntax
output "fixed_output" {
  value = aws_instance.fixed_instance.id
}
EOF
```

**5️⃣ Run validation again:**
```bash
terraform validate
```

### 🧬 Subtask 3.4: Advanced Validation Techniques

**1️⃣ Validate with JSON output:**
```bash
terraform validate -json
```

**2️⃣ Create a comprehensive validation script:**
```bash
cat > validate-all.sh << 'EOF'
#!/bin/bash

echo "=== Terraform Quality Assurance Report ==="
echo "Date: $(date)"
echo "Directory: $(pwd)"
echo ""

echo "1. Running Terraform Format Check..."
terraform fmt -check -diff
echo ""

echo "2. Running Terraform Validation..."
terraform validate
if [ $? -eq 0 ]; then
    echo "✓ Terraform validation passed"
else
    echo "✗ Terraform validation failed"
fi
echo ""

echo "3. Running tflint Analysis..."
tflint
echo ""

echo "4. Running tfsec Security Scan..."
tfsec --format=compact .
echo ""

echo "5. Generating Summary Reports..."
echo "- tflint report: tflint-report.json"
echo "- tfsec report: tfsec-report.json"
echo "- HTML security report: tfsec-report.html"

echo ""
echo "=== Quality Assurance Complete ==="
EOF

chmod +x validate-all.sh
```

**3️⃣ Run the comprehensive validation:**
```bash
./validate-all.sh
```

---

## 🚦 Task 4: Implement Quality Assurance Workflow

### 🪝 Subtask 4.1: Create Pre-commit Hooks

**1️⃣ Install pre-commit (if available):**
```bash
# 🐍 Install pip if not available
sudo apt install -y python3-pip

# 📦 Install pre-commit
pip3 install pre-commit
```

**2️⃣ Create pre-commit configuration:**
```yaml
cat > .pre-commit-config.yaml << 'EOF'
repos:
  - repo: https://github.com/antonbabenko/pre-commit-terraform
    rev: v1.81.0
    hooks:
      - id: terraform_fmt
      - id: terraform_validate
      - id: terraform_tflint
      - id: terraform_tfsec
EOF
```

### 🚧 Subtask 4.2: Create Quality Gates

**1️⃣ Create a quality gate script:**
```bash
cat > quality-gate.sh << 'EOF'
#!/bin/bash

# 🚦 Quality Gate Script for Terraform
set -e

FAILED_CHECKS=0

echo "🔍 Starting Terraform Quality Gate..."

# Check 1: Terraform Format
echo "📝 Checking Terraform formatting..."
if ! terraform fmt -check -diff; then
    echo "❌ Terraform formatting check failed"
    FAILED_CHECKS=$((FAILED_CHECKS + 1))
else
    echo "✅ Terraform formatting check passed"
fi

# Check 2: Terraform Validation
echo "🔧 Validating Terraform configuration..."
if ! terraform validate; then
    echo "❌ Terraform validation failed"
    FAILED_CHECKS=$((FAILED_CHECKS + 1))
else
    echo "✅ Terraform validation passed"
fi

# Check 3: tflint
echo "🔍 Running tflint analysis..."
if ! tflint; then
    echo "❌ tflint analysis failed"
    FAILED_CHECKS=$((FAILED_CHECKS + 1))
else
    echo "✅ tflint analysis passed"
fi

# Check 4: tfsec
echo "🔒 Running security scan with tfsec..."
if ! tfsec --soft-fail .; then
    echo "⚠️  Security issues found (soft fail)"
    # Don't increment FAILED_CHECKS for soft fail
else
    echo "✅ Security scan passed"
fi

# Final result
echo ""
if [ $FAILED_CHECKS -eq 0 ]; then
    echo "🎉 All quality gates passed! Configuration is ready for deployment."
    exit 0
else
    echo "💥 $FAILED_CHECKS quality gate(s) failed. Please fix the issues before proceeding."
    exit 1
fi
EOF

chmod +x quality-gate.sh
```

**2️⃣ Run the quality gate:**
```bash
./quality-gate.sh
```

> 🎓 **TODO:** Wire `quality-gate.sh` into a CI job (GitHub Actions or Jenkins) so it runs automatically on every pull request against your Terraform repo.

### 📊 Subtask 4.3: Generate Comprehensive Reports

**1️⃣ Create a report generation script:**
```bash
cat > generate-reports.sh << 'EOF'
#!/bin/bash

REPORT_DIR="qa-reports"
mkdir -p $REPORT_DIR

echo "📊 Generating comprehensive QA reports..."

# Generate tflint report
echo "Generating tflint report..."
tflint --format=json > $REPORT_DIR/tflint-report.json
tflint --format=compact > $REPORT_DIR/tflint-report.txt

# Generate tfsec reports
echo "Generating tfsec reports..."
tfsec --format=json . > $REPORT_DIR/tfsec-report.json
tfsec --format=html . > $REPORT_DIR/tfsec-report.html
tfsec --format=csv . > $REPORT_DIR/tfsec-report.csv

# Generate terraform validation report
echo "Generating terraform validation report..."
terraform validate -json > $REPORT_DIR/terraform-validate.json

# Create summary report
cat > $REPORT_DIR/summary.md << 'SUMMARY'
# Terraform Quality Assurance Summary

## Report Generation Date
$(date)

## Files Analyzed
$(find . -name "*.tf" -type f | wc -l) Terraform files

## Reports Generated
- tflint-report.json: Detailed linting analysis
- tflint-report.txt: Human-readable linting report
- tfsec-report.json: Security analysis (JSON)
- tfsec-report.html: Security analysis (HTML)
- tfsec-report.csv: Security analysis (CSV)
- terraform-validate.json: Syntax validation results

## Quick Stats
- Total .tf files: $(find . -name "*.tf" -type f | wc -l)
- Total lines of code: $(find . -name "*.tf" -exec wc -l {} + | tail -1 | awk '{print $1}')

SUMMARY

echo "✅ Reports generated in $REPORT_DIR/"
ls -la $REPORT_DIR/
EOF

chmod +x generate-reports.sh
```

**2️⃣ Generate the reports:**
```bash
./generate-reports.sh
```

**3️⃣ View the HTML security report (if GUI available):**
```bash
# 🌐 Display the path to view in browser
echo "Security report available at: $(pwd)/qa-reports/tfsec-report.html"
```

---

## 🛠️ Troubleshooting Common Issues

<details>
<summary>❗ Issue 1: tflint Plugin Installation Fails</summary>

**Problem:** tflint fails to download AWS plugin

**Solution:**
```bash
# 🔧 Manually specify plugin version
cat > .tflint.hcl << 'EOF'
plugin "aws" {
  enabled = true
  version = "0.24.1"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}
EOF

# 🧹 Clear cache and reinitialize
rm -rf .tflint.d/
tflint --init
```
</details>

<details>
<summary>❗ Issue 2: tfsec Shows Too Many False Positives</summary>

**Problem:** tfsec reports issues that are acceptable for your use case

**Solution:**
```yaml
# 📝 Create tfsec ignore file
cat > .tfsec/config.yml << 'EOF'
severity_overrides:
  aws-s3-enable-bucket-encryption: LOW
  aws-ec2-no-public-ingress-sgr: MEDIUM

exclude:
  - aws-s3-enable-bucket-logging
EOF
```
</details>

<details>
<summary>❗ Issue 3: Terraform Validate Fails with Provider Issues</summary>

**Problem:** Validation fails due to provider configuration

**Solution:**
```bash
# ⏭️ Skip provider validation for syntax checking
terraform validate -no-color
```
</details>

---

## 🧠 Key Concepts

| Concept | Tool / Technique | Purpose |
|---------|-------------------|---------|
| 🧹 Static Linting | `tflint` + AWS ruleset plugin | Catches best-practice violations, unused declarations, and deprecated syntax before apply |
| 🔒 Security Scanning | `tfsec` | Detects misconfigurations — public access, missing encryption, hardcoded secrets, wildcard IAM |
| ✅ Syntax Validation | `terraform validate` | Confirms configuration is internally consistent and syntactically valid |
| 🎯 Severity Filtering | `tfsec --minimum-severity` | Focuses remediation effort on HIGH/CRITICAL findings first |
| 🪝 Shift-Left Automation | `pre-commit` + `pre-commit-terraform` | Runs fmt/validate/tflint/tfsec locally before code is ever committed |
| 🚦 Quality Gates | `quality-gate.sh` | Blocks deployment on hard failures while allowing soft-fail security triage |
| 📊 Reporting | JSON / HTML / CSV exports | Produces auditable, shareable evidence of QA coverage per run |

---

## 🏁 Lab Summary

In this comprehensive lab, you have successfully:

- ✅ Installed and configured **tflint** to analyze Terraform configurations for best practices, identifying issues such as unused variables, deprecated syntax, and naming convention violations
- ✅ Implemented **tfsec** security scanning to detect potential security vulnerabilities including overly permissive security groups, unencrypted storage, hardcoded credentials, and excessive IAM permissions
- ✅ Used **terraform validate** to ensure syntax correctness and configuration validity, catching basic errors before deployment
- ✅ Created a comprehensive quality assurance workflow that combines multiple tools to provide thorough analysis of infrastructure code
- ✅ Generated detailed reports in multiple formats (JSON, HTML, CSV) for documentation and compliance purposes
- ✅ Established quality gates that can be integrated into CI/CD pipelines to prevent problematic code from reaching production

### 🌍 Real-World Applications

This lab demonstrates the critical importance of implementing automated testing and quality assurance in Infrastructure as Code workflows. By using these tools together, you can significantly reduce the risk of deploying insecure or misconfigured infrastructure, improve code quality, and maintain consistency across your Terraform projects.

The skills learned in this lab are essential for maintaining production-ready infrastructure code and implementing DevSecOps practices in cloud environments. These tools help catch issues early in the development cycle, reducing costs and security risks associated with infrastructure deployment.

---

<div align="center">

![Al Nafi](https://img.shields.io/badge/Al%20Nafi-Cybersecurity%20Training-blueviolet?style=for-the-badge)

</div>
