resource "aws_s3_bucket" "imported_bucket" {
  bucket = "my-existing-bucket"
}

resource "aws_s3_bucket_versioning" "imported_bucket_versioning" {
  bucket = aws_s3_bucket.imported_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_bucket" "imported_bucket" {
  bucket = "my-existing-bucket"

  tags = {
    Environment = "lab"
    Purpose     = "terraform-import-demo"
    ManagedBy   = "terraform"
  }
}

resource "aws_s3_bucket_versioning" "imported_bucket_versioning" {
  bucket = aws_s3_bucket.imported_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "imported_bucket_encryption" {
  bucket = aws_s3_bucket.imported_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "imported_bucket_pab" {
  bucket = aws_s3_bucket.imported_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "second_imported_bucket" {
  bucket = "another-existing-bucket"

  tags = {
    Environment = "lab"
    Purpose     = "advanced-import-demo"
    ManagedBy   = "terraform"
  }
}

resource "aws_s3_bucket_policy" "second_bucket_policy" {
  bucket = aws_s3_bucket.second_imported_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyInsecureConnections"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.second_imported_bucket.arn,
          "${aws_s3_bucket.second_imported_bucket.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

