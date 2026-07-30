# Configure the local provider for demonstration
terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
  required_version = ">= 1.0"
}

# Define variables for environment-specific configuration
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "default"
}

variable "instance_count" {
  description = "Number of instances to create"
  type        = number
  default     = 1
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "myapp"
}

# Create environment-specific local files
resource "local_file" "environment_config" {
  count    = var.instance_count
  filename = "${path.module}/environments/${var.environment}-${var.app_name}-${count.index + 1}.txt"
  content  = <<-EOT
    Environment: ${var.environment}
    Application: ${var.app_name}
    Instance: ${count.index + 1}
    Workspace: ${terraform.workspace}
    Timestamp: ${timestamp()}
  EOT
}

resource "local_file" "workspace_info" {
  filename = "${path.module}/environments/${terraform.workspace}-workspace-info.json"
  content = jsonencode({
    workspace     = terraform.workspace
    environment   = var.environment
    instance_count = var.instance_count
    app_name      = var.app_name
    created_at    = timestamp()
  })
}

# Output important information
output "workspace_name" {
  description = "Current workspace name"
  value       = terraform.workspace
}

output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "files_created" {
  description = "List of files created"
  value       = local_file.environment_config[*].filename
}
EOF
