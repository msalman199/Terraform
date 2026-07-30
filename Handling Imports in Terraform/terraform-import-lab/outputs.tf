output "bucket_name" {
  description = "Name of the imported S3 bucket"
  value       = aws_s3_bucket.imported_bucket.bucket
}

output "bucket_arn" {
  description = "ARN of the imported S3 bucket"
  value       = aws_s3_bucket.imported_bucket.arn
}

output "bucket_domain_name" {
  description = "Domain name of the S3 bucket"
  value       = aws_s3_bucket.imported_bucket.bucket_domain_name
}

output "versioning_status" {
  description = "Versioning status of the bucket"
  value       = aws_s3_bucket_versioning.imported_bucket_versioning.versioning_configuration[0].status
}
