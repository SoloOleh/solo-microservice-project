output "s3_bucket_url" {
  description = "URL S3 бакета для Terraform state"
  value       = module.s3_backend.s3_bucket_url
}

output "dynamodb_table_name" {
  description = "Ім'я DynamoDB таблиці для блокування Terraform state"
  value       = module.s3_backend.dynamodb_table_name
}

output "ecr_repository_url" {
  description = "URL ECR репозиторію"
  value       = module.ecr.repository_url
}

output "vpc_id" {
  description = "ID створеної VPC"
  value       = module.vpc.vpc_id
}