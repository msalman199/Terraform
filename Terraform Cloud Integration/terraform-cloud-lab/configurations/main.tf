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

# Random string resource
resource "random_string" "lab_id" {
  length  = 8
  special = false
  upper   = false
}

# Local file resource
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

# Output values
output "lab_id" {
  description = "Unique identifier for this lab run"
  value       = random_string.lab_id.result
}

output "output_file" {
  description = "Path to the generated output file"
  value       = local_file.lab_output.filename
}
EOF
