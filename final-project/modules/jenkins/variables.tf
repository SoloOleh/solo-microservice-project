variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the EKS OIDC provider"
  type        = string
}

variable "oidc_provider_url" {
  description = "URL of the EKS OIDC provider"
  type        = string
}

variable "namespace" {
  description = "Namespace where Jenkins will be installed"
  type        = string
  default     = "jenkins"
}

variable "release_name" {
  description = "Jenkins Helm release name"
  type        = string
  default     = "jenkins"
}

variable "chart_version" {
  description = "Version of the Jenkins Helm chart"
  type        = string
  default     = "5.8.27"
}
