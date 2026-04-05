output "s3_bucket_url" {
  description = "URL створеного S3-бакета"
  value       = aws_s3_bucket.terraform_state.bucket_regional_domain_name
}

output "dynamodb_table_name" {
  description = "Назва створеної DynamoDB таблиці"
  value       = aws_dynamodb_table.terraform_locks.name
}