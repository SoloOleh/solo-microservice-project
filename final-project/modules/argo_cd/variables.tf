variable "name" {
  description = "Argo CD Helm release name"
  type        = string
  default     = "argocd"
}

variable "namespace" {
  description = "Namespace where Argo CD will be installed"
  type        = string
  default     = "argocd"
}

variable "chart_version" {
  description = "Version of the Argo CD Helm chart"
  type        = string
  default     = "5.46.4"
}

variable "repo_url" {
  description = "GitHub repository URL for the Argo CD Application"
  type        = string
}

variable "target_revision" {
  description = "Git branch for the Argo CD Application"
  type        = string
  default     = "final-project"
}

variable "app_chart_path" {
  description = "Path to the Django Helm chart inside the repository"
  type        = string
}

variable "app_namespace" {
  description = "Kubernetes namespace where the Django app will be deployed"
  type        = string
  default     = "default"
}

variable "image_repository" {
  description = "ECR image repository URL"
  type        = string
}

variable "db_host" {
  description = "Database endpoint passed to Django through Argo CD Helm parameters"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_username" {
  description = "Database username"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}
