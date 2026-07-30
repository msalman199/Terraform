# Create a local file resource
resource "local_file" "welcome_file" {
  filename = "${path.module}/welcome.txt"
  content  = "Welcome to Terraform Lab 8!\nThis file was created by Terraform.\nTimestamp: ${timestamp()}"
}

# Create a directory structure
resource "local_file" "config_file" {
  filename = "${path.module}/configs/app.conf"
  content  = <<-EOT
    [application]
    name = terraform-demo
    version = 1.0.0
    environment = development
    
    [database]
    host = localhost
    port = 5432
    name = demo_db
  EOT
}

# Create a JSON configuration file
resource "local_file" "json_config" {
  filename = "${path.module}/configs/settings.json"
  content = jsonencode({
    app_name    = "terraform-lab"
    debug_mode  = true
    max_connections = 100
    features = [
      "logging",
      "monitoring",
      "caching"
    ]
  })
}
