terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
  # For demo purposes - in real scenarios, use proper authentication
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
}

# This IAM policy violates least privilege (wildcard permissions)
resource "aws_iam_policy" "bad_policy" {
  name = "overly-permissive-policy"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "*"
        Resource = "*"
      }
    ]
  })
}

# This IAM role can be assumed by anyone (security risk)
resource "aws_iam_role" "bad_role" {
  name = "insecure-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "*"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# This security group allows unrestricted access
resource "aws_security_group" "bad_sg" {
  name_prefix = "insecure-sg"
  
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Missing required tags
}

# This security group allows SSH from anywhere
resource "aws_security_group" "ssh_sg" {
  name_prefix = "ssh-sg"
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    # Missing description
  }
  
  tags = {
    Name = "SSH Security Group"
    # Missing required tags
  }
}

# This S3 bucket is missing required tags
resource "aws_s3_bucket" "example_bucket" {
  bucket = "my-example-bucket-${random_string.bucket_suffix.result}"
  
  tags = {
    Name = "Example Bucket"
    # Missing required tags: Environment, Owner, Project, CostCenter
  }
}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}
