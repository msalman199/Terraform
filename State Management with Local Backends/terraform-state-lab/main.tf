# Configure Terraform settings and required providers
terraform {
  required_version = ">= 1.0"
  
  # Configure local backend for state storage
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

# Configure the local provider
provider "local" {}
provider "random" {}

# Create a random string resource
resource "random_string" "lab_id" {
  length  = 8
  special = false
  upper   = false
}

# Create a local file resource
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

# Create a sensitive file with restricted permissions
resource "local_sensitive_file" "credentials" {
  filename = "./configs/credentials-${random_string.lab_id.result}.txt"
  content  = <<-EOT
    # Sensitive Configuration File
    api_key: secret-key-${random_string.lab_id.result}
    database_password: db-pass-${random_string.lab_id.result}
  EOT
  file_permission = "0600"
}

# Output values for verification
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
