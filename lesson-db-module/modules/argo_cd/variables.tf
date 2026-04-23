variable "name" {
  description = "Argo CD Helm release name"
  type        = string
  default     = "argo-cd"
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
