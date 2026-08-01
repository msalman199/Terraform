terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

resource "local_file" "deployment_summary" {
  filename = "deployment-summary.json"
  content = jsonencode({
    environment         = var.environment
    deployment_strategy = local.deployment_strategy
    labels              = local.computed_labels
    exposed_ports       = local.exposed_ports
  })
}
