variable "ecr_name" {
  description = "Назва ECR репозиторію"
  type        = string
}

variable "scan_on_push" {
  description = "Увімкнути автоматичне сканування образів"
  type        = bool
  default     = true
}