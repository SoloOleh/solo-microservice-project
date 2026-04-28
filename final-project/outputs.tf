output "s3_bucket_name" {
  description = "Name of the S3 bucket for storing Terraform state"
  value       = module.s3_backend.s3_bucket_name
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table used for state locking"
  value       = module.s3_backend.dynamodb_table_name
}

output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnets
}

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = module.ecr.repository_url
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.eks_cluster_name
}

output "eks_cluster_endpoint" {
  description = "API endpoint of the EKS cluster"
  value       = module.eks.eks_cluster_endpoint
}

output "database_endpoint" {
  description = "RDS endpoint when use_aurora=false, or Aurora writer endpoint when use_aurora=true"
  value       = var.use_aurora ? module.rds.aurora_cluster_endpoint : module.rds.rds_endpoint
}

output "jenkins_release_name" {
  description = "Installed Jenkins release name"
  value       = module.jenkins.jenkins_release_name
}

output "jenkins_namespace" {
  description = "Namespace where Jenkins is installed"
  value       = module.jenkins.jenkins_namespace
}

output "argo_cd_release_name" {
  description = "Installed Argo CD release name"
  value       = module.argo_cd.argo_cd_release_name
}

output "argo_cd_namespace" {
  description = "Namespace where Argo CD is installed"
  value       = module.argo_cd.argo_cd_namespace
}

output "monitoring_namespace" {
  description = "Namespace where Prometheus and Grafana are installed"
  value       = module.monitoring.monitoring_namespace
}

output "jenkins_port_forward" {
  description = "Command for opening Jenkins locally"
  value       = "kubectl port-forward svc/jenkins 8080:8080 -n jenkins"
}

output "argocd_port_forward" {
  description = "Command for opening Argo CD locally"
  value       = "kubectl port-forward svc/argocd-server 8081:443 -n argocd"
}

output "grafana_port_forward" {
  description = "Command for opening Grafana locally"
  value       = "kubectl port-forward svc/grafana 3000:80 -n monitoring"
}

output "argocd_admin_password_command" {
  description = "Command for getting the initial Argo CD admin password"
  value       = "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d && echo"
}

output "grafana_credentials" {
  description = "Default Grafana credentials for this homework project"
  value       = "admin / admin123"
}
