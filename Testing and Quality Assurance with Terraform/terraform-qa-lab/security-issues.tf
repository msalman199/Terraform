# Additional security issues for testing

# RDS instance without encryption
resource "aws_db_instance" "database" {
  identifier = "mydb"
  engine     = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"
  allocated_storage = 20
  
  db_name  = "myapp"
  username = "admin"
  password = "password123"  # Hardcoded password - security issue
  
  # Missing encryption
  storage_encrypted = false
  
  # Public access enabled - security issue
  publicly_accessible = true
  
  skip_final_snapshot = true
}

# S3 bucket without proper security
resource "aws_s3_bucket" "insecure_bucket" {
  bucket = "insecure-bucket-example"
}

resource "aws_s3_bucket_public_access_block" "insecure_bucket_pab" {
  bucket = aws_s3_bucket.insecure_bucket.id
  
  # Allowing public access - security issue
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# IAM policy with overly broad permissions
resource "aws_iam_policy" "overly_permissive" {
  name        = "overly-permissive-policy"
  description = "Policy with too many permissions"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "*"  # Security issue: wildcard permissions
        Resource = "*"
      }
    ]
  })
}
