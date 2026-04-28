output "monitoring_namespace" {
  description = "Namespace where Prometheus and Grafana are installed"
  value       = var.namespace
}

output "prometheus_release_name" {
  description = "Prometheus Helm release name"
  value       = var.prometheus_release_name
}

output "grafana_release_name" {
  description = "Grafana Helm release name"
  value       = var.grafana_release_name
}
