terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

# Local file resources
resource "local_file" "app_config" {
  filename = "${path.module}/app-config.txt"
  content  = <<-EOT
    Application Configuration
    Environment: Development
    Version: 1.0.0
    Database: localhost:5432
    Cache: redis://localhost:6379
  EOT
}

resource "local_file" "database_config" {
  filename = "${path.module}/database-config.txt"
  content  = <<-EOT
    Database Configuration
    Host: localhost
    Port: 5432
    Database: myapp_dev
    Username: developer
    SSL: enabled
  EOT
}

resource "local_file" "nginx_config" {
  filename = "${path.module}/nginx.conf"
  content  = <<-EOT
    server {
        listen 80;
        server_name localhost;
        
        location / {
            proxy_pass http://localhost:3000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
    }
  EOT
}

# Null resources for demonstration
resource "null_resource" "app_setup" {
  provisioner "local-exec" {
    command = "echo 'Application setup completed' > app-setup.log"
  }
  
  depends_on = [local_file.app_config]
}

resource "null_resource" "database_setup" {
  provisioner "local-exec" {
    command = "echo 'Database setup completed at $(date)' > database-setup.log"
  }
  
  depends_on = [local_file.database_config]
}


resource "local_file" "app_config" {
  filename = "${path.module}/app-config.txt"
  content  = <<-EOT
    Application Configuration
    Environment: ${var.environment}
    Version: ${var.app_version}
    Database: localhost:5432
    Cache: redis://localhost:6379
    Updated: ${timestamp()}
  EOT
}
resource "local_file" "web_server_config" {
  filename = "${path.module}/nginx.conf"
  content  = <<-EOT
    server {
        listen 80;
        server_name localhost;
        
        location / {
            proxy_pass http://localhost:3000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
    }
  EOT
}
