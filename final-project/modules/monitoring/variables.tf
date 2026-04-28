variable "namespace" {
  description = "Namespace where Prometheus and Grafana will be installed"
  type        = string
  default     = "monitoring"
}

variable "prometheus_release_name" {
  description = "Prometheus Helm release name"
  type        = string
  default     = "prometheus"
}

variable "grafana_release_name" {
  description = "Grafana Helm release name"
  type        = string
  default     = "grafana"
}

variable "metrics_server_release_name" {
  description = "Metrics Server Helm release name"
  type        = string
  default     = "metrics-server"
}
