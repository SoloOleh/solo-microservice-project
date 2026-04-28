variable "name" {
  description = "Базова назва для RDS instance або Aurora cluster"
  type        = string
}

variable "use_aurora" {
  description = "Якщо true - створюється Aurora cluster, якщо false - звичайний RDS instance"
  type        = bool
  default     = false
}

variable "engine" {
  description = "Тип двигуна для звичайного RDS instance (наприклад: postgres або mysql)"
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "Версія двигуна для звичайного RDS instance"
  type        = string
  default     = "17.2"
}

variable "engine_cluster" {
  description = "Тип двигуна для Aurora cluster (наприклад: aurora-postgresql або aurora-mysql)"
  type        = string
  default     = "aurora-postgresql"
}

variable "engine_version_cluster" {
  description = "Версія двигуна для Aurora cluster"
  type        = string
  default     = "15.3"
}

variable "instance_class" {
  description = "Клас інстансу БД"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Розмір диска у GB для звичайного RDS instance"
  type        = number
  default     = 20
}

variable "aurora_instance_count" {
  description = "Загальна кількість Aurora інстансів: 1 writer + решта readers"
  type        = number
  default     = 2
}

variable "db_name" {
  description = "Назва початкової бази даних"
  type        = string
}

variable "username" {
  description = "Майстер-користувач бази даних"
  type        = string
}

variable "password" {
  description = "Пароль майстер-користувача бази даних"
  type        = string
  sensitive   = true
}

variable "vpc_id" {
  description = "ID VPC, у якій буде створено security group"
  type        = string
}

variable "subnet_private_ids" {
  description = "Список приватних subnet ID"
  type        = list(string)
}

variable "subnet_public_ids" {
  description = "Список публічних subnet ID"
  type        = list(string)
  default     = []
}

variable "publicly_accessible" {
  description = "Чи буде БД публічно доступною"
  type        = bool
  default     = false
}

variable "multi_az" {
  description = "Чи вмикати Multi-AZ для звичайного RDS instance"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Кількість днів зберігання backup"
  type        = number
  default     = 0
}

variable "parameter_group_family_rds" {
  description = "Family для aws_db_parameter_group звичайного RDS"
  type        = string
  default     = "postgres17"
}

variable "parameter_group_family_aurora" {
  description = "Family для aws_rds_cluster_parameter_group Aurora"
  type        = string
  default     = "aurora-postgresql15"
}

variable "parameters" {
  description = "Параметри для parameter group у форматі map(name = value)"
  type        = map(string)
  default = {
    max_connections = "200"
    log_statement   = "ddl"
    work_mem        = "4096"
  }
}

variable "allowed_cidr_blocks" {
  description = "CIDR-блоки, яким дозволено доступ до БД"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "Теги для ресурсів"
  type        = map(string)
  default     = {}
}
