# Additional random resources
resource "random_password" "lab_password" {
  length  = 16
  special = true
}

resource "random_uuid" "lab_uuid" {}

# Local file with more complex content
resource "local_file" "advanced_output" {
  filename = "${path.module}/advanced-${random_string.lab_id.result}.json"
  content = jsonencode({
    lab_info = {
      id          = random_string.lab_id.result
      uuid        = random_uuid.lab_uuid.result
      environment = var.environment
      project     = var.project_name
      timestamp   = timestamp()
      tags        = var.tags
    }
    security = {
      password_length = length(random_password.lab_password.result)
      has_special     = random_password.lab_password.special
    }
  })
}

# Additional outputs
output "lab_uuid" {
  description = "UUID for this lab session"
  value       = random_uuid.lab_uuid.result
}

output "advanced_file" {
  description = "Path to the advanced JSON output file"
  value       = local_file.advanced_output.filename
}
EOF
