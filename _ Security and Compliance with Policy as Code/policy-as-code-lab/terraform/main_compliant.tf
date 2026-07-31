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

# Compliant IAM policy with specific permissions
resource "aws_iam_policy" "good_policy" {
  name = "least-privilege-policy"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "arn:aws:s3:::my-specific-bucket/*"
      }
    ]
  })
  
  tags = {
    Environment = "dev"
    Owner       = "security-team"
    Project     = "compliance-demo"
    CostCenter  = "IT-001"
  }
}

# Compliant IAM role with specific principal
resource "aws_iam_role" "good_role" {
  name = "secure-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::123456789012:root"
        }
        Action = "sts:AssumeRole"
        Condition = {
          Bool = {
            "aws:MultiFactorAuthPresent" = "true"
          }
        }
      }
    ]
  })
  
  tags = {
    Environment = "prod"
    Owner       = "security-team"
    Project     = "compliance-demo"
    CostCenter  = "IT-001"
  }
}

# Compliant security group with restricted access
resource "aws_security_group" "good_sg" {
  name_prefix = "secure-sg"
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "HTTPS access from internal network"
  }
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
    description = "SSH access from management subnet"
  }
  
  tags = {
    Name        = "Secure Security Group"
    Environment = "prod"
    Owner       = "network-team"
    Project     = "compliance-demo"
    CostCenter  = "IT-001"
  }
}

# Compliant S3 bucket with all required tags
resource "aws_s3_bucket" "compliant_bucket" {
  bucket = "compliant-bucket-${random_string.compliant_suffix.result}"
  
  tags = {
    Name        = "Compliant Bucket"
    Environment = "prod"
    Owner       = "data-team"
    Project     = "compliance-demo"
    CostCenter  = "IT-001"
  }
}

resource "random_string" "compliant_suffix" {
  length  = 8
  special = false
  upper   = false
}
