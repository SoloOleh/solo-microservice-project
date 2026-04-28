output "jenkins_release_name" {
  description = "Jenkins Helm release name"
  value       = var.release_name
}

output "jenkins_namespace" {
  description = "Namespace where Jenkins is installed"
  value       = var.namespace
}

output "jenkins_admin_password_command" {
  description = "Command to get Jenkins admin password"
  value       = "kubectl get secret jenkins -n ${var.namespace} -o jsonpath='{.data.jenkins-admin-password}' | base64 -d && echo"
}
