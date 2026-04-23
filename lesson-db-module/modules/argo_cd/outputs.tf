output "argo_cd_release_name" {
  description = "Argo CD Helm release name"
  value       = helm_release.argo_cd.name
}

output "argo_cd_namespace" {
  description = "Namespace where Argo CD is installed"
  value       = helm_release.argo_cd.namespace
}

output "argo_cd_admin_password_command" {
  description = "Command to get Argo CD initial admin password"
  value       = "kubectl -n ${var.namespace} get secret argocd-initial-admin-secret -o jsonpath={.data.password} | base64 -d"
}
