variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "terraform-lab"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "development"
}

variable "debug_mode" {
  description = "Enable debug mode"
  type        = bool
  default     = true
}

variable "max_connections" {
  description = "Maximum number of connections"
  type        = number
  default     = 100
}
