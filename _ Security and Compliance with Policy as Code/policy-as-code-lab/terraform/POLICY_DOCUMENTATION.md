# Security and Compliance Policies

## Overview

This document describes the security and compliance policies implemented using Open Policy Agent (OPA) for Terraform infrastructure as code.

## Policy Categories

### 1. IAM Least Privilege Policies

**File**: `policies/aws_iam_least_privilege.rego`

**Purpose**: Enforce least privilege access principles for AWS IAM resources.

**Rules**:
- **Deny wildcard permissions**: Prevents IAM policies with `*:*` permissions
- **Deny open role assumptions**: Prevents IAM roles that can be assumed by any AWS account
- **Require MFA for sensitive actions**: Enforces MFA for critical IAM operations
- **Warn about broad S3 permissions**: Alerts on overly permissive S3 access

### 2. Security Group Policies

**File**: `policies/aws_security_groups.rego`

**Purpose**: Enforce network security best practices for AWS security groups.

**Rules**:
- **Deny unrestricted inbound access**: Prevents security groups allowing all traffic from anywhere
- **Deny SSH from anywhere**: Blocks SSH access (port 22) from 0.0.0.0/0
- **Deny RDP from anywhere**: Blocks RDP access (port 3389) from 0.0.0.0/0
- **Require rule descriptions**: Enforces documentation for security group rules
- **Warn about risky ports**: Alerts when commonly attacked ports are exposed

### 3. Resource Tagging Policies

**File**: `policies/aws_tagging.rego`

**Purpose**: Enforce consistent resource tagging for cost management and governance.

**Rules**:
- **Required tags**: Enforces presence of Environment, Owner, Project, CostCenter tags
- **Environment tag validation**: Ensures Environment tag uses approved values
- **Tag count warning**: Alerts when resources have excessive tags

## Policy Testing

### Using Conftest

```bash
# Test all policies against Terraform plan
conftest test --policy ./policies terraform/plan.json

# Test specific policy
conftest test --policy ./policies/aws_iam_least_privilege.rego terraform/plan.json
