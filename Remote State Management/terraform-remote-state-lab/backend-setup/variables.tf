variable "bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  type        = string
  default     = "terraform-state-bucket-unique-12345"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "lab"
}
