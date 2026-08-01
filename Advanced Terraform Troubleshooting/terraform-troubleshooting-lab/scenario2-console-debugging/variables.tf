variable "environment" {
  description = "Environment name"
  type        = string
  default     = "development"
}

variable "application_config" {
  description = "Application configuration"
  type = object({
    name     = string
    version  = string
    replicas = number
    ports    = list(number)
  })
  default = {
    name     = "web-app"
    version  = "1.0.0"
    replicas = 3
    ports    = [80, 443, 8080]
  }
}
