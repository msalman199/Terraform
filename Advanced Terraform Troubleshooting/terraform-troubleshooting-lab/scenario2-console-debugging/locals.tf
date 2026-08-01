locals {
  deployment_strategy = var.environment == "production" ? "blue-green" : "rolling"

  exposed_ports = [
    for port in var.application_config.ports : port
    if port != 8080
  ]

  computed_labels = {
    environment = var.environment
    app_name    = var.application_config.name
    app_version = var.application_config.version
  }
}
