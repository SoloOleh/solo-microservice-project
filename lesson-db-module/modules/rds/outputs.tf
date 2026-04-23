output "db_subnet_group_name" {
  description = "Назва DB subnet group"
  value       = aws_db_subnet_group.default.name
}

output "security_group_id" {
  description = "ID security group для БД"
  value       = aws_security_group.rds.id
}

output "rds_instance_id" {
  description = "ID звичайного RDS instance, якщо use_aurora = false"
  value       = var.use_aurora ? null : aws_db_instance.standard[0].id
}

output "rds_endpoint" {
  description = "Endpoint звичайного RDS instance, якщо use_aurora = false"
  value       = var.use_aurora ? null : aws_db_instance.standard[0].address
}

output "aurora_cluster_id" {
  description = "ID Aurora cluster, якщо use_aurora = true"
  value       = var.use_aurora ? aws_rds_cluster.aurora[0].id : null
}

output "aurora_cluster_endpoint" {
  description = "Writer endpoint Aurora cluster, якщо use_aurora = true"
  value       = var.use_aurora ? aws_rds_cluster.aurora[0].endpoint : null
}

output "aurora_reader_endpoint" {
  description = "Reader endpoint Aurora cluster, якщо use_aurora = true"
  value       = var.use_aurora ? aws_rds_cluster.aurora[0].reader_endpoint : null
}
