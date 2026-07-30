# Variables for AWS configuration
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "AWS Key Pair name for EC2 access"
  type        = string
  default     = "my-terraform-key"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}
