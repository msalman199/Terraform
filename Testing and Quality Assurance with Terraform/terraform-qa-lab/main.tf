# Sample Terraform configuration with intentional issues
terraform {
  required_version = ">= 0.12"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

# EC2 instance with issues
resource "aws_instance" "web_server" {
  ami           = "ami-0c02fb55956c7d316"  # Hardcoded AMI
  instance_type = "t2.micro"
  
  # Security group allowing all traffic (security issue)
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  
  # Missing tags
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
  EOF
}

# Security group with overly permissive rules
resource "aws_security_group" "web_sg" {
  name_prefix = "web-sg"
  description = "Security group for web server"
  
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Security issue: too permissive
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# S3 bucket with potential issues
resource "aws_s3_bucket" "data_bucket" {
  bucket = "my-data-bucket-12345"  # Hardcoded bucket name
}

# Unused variable (will trigger warning)
variable "unused_var" {
  description = "This variable is not used anywhere"
  type        = string
  default     = "unused"
}

# Output without description
output "instance_ip" {
  value = aws_instance.web_server.public_ip
}
EOF
