output "deployment_info" {
  description = "Deployment information"
  value = {
    strategy      = local.deployment_strategy
    exposed_ports = local.exposed_ports
    environment   = var.environment
  }
}
