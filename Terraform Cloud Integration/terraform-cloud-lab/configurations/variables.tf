variable "environment" {
  description = "Environment name for the lab"
  type        = string
  default     = "development"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "terraform-cloud-lab"
}

variable "tags" {
  description = "Common tags for resources"
  type        = map(string)
  default = {
    Environment = "development"
    Project     = "terraform-cloud-lab"
    ManagedBy   = "terraform-cloud"
  }
}
EOF
