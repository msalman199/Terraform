terraform {
  required_version = ">= 1.0"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

resource "local_file" "example" {
  content  = "Hello from Terraform - Version 1"
  filename = "${path.module}/example.txt"
}

resource "local_file" "config" {
  content  = "config_version=1.0\nstatus=active"
  filename = "${path.module}/config/app.conf"
}

output "file_content" {
  value = local_file.example.content
}
