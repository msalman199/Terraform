resource "aws_s3_bucket" "imported_bucket" {
  bucket = "my-existing-bucket"
}

resource "aws_s3_bucket_versioning" "imported_bucket_versioning" {
  bucket = aws_s3_bucket.imported_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
