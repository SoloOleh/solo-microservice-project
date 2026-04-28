terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "s3_backend" {
  source      = "./modules/s3-backend"
  bucket_name = var.s3_backend_bucket
  table_name  = var.dynamodb_table
}

module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr_block     = var.vpc_cidr_block
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  availability_zones = var.availability_zones
  vpc_name           = "final-project-vpc"
  cluster_name       = var.eks_cluster_name
}

module "ecr" {
  source       = "./modules/ecr"
  ecr_name     = var.ecr_repo_name
  scan_on_push = true
}

module "eks" {
  source             = "./modules/eks"
  region             = var.aws_region
  cluster_name       = var.eks_cluster_name
  cluster_subnet_ids = concat(module.vpc.public_subnets, module.vpc.private_subnets)
  node_subnet_ids    = module.vpc.private_subnets
  instance_type      = var.eks_node_instance_type
  desired_size       = var.eks_desired_size
  max_size           = var.eks_max_size
  min_size           = var.eks_min_size

  depends_on = [module.vpc]
}

module "rds" {
  source = "./modules/rds"

  name                  = "final-project-db"
  use_aurora            = var.use_aurora
  aurora_instance_count = 2

  # Aurora-only settings. They are used only when use_aurora = true.
  engine_cluster                = "aurora-postgresql"
  engine_version_cluster        = "15.3"
  parameter_group_family_aurora = "aurora-postgresql15"

  # Standard RDS settings. They are used only when use_aurora = false.
  engine                     = "postgres"
  engine_version             = "17.2"
  parameter_group_family_rds = "postgres17"

  # Common database settings.
  instance_class          = var.db_instance_class
  allocated_storage       = 20
  db_name                 = var.db_name
  username                = var.db_username
  password                = var.db_password
  subnet_private_ids      = module.vpc.private_subnets
  subnet_public_ids       = module.vpc.public_subnets
  publicly_accessible     = false
  vpc_id                  = module.vpc.vpc_id
  multi_az                = false
  backup_retention_period = 0
  allowed_cidr_blocks     = [var.vpc_cidr_block]

  parameters = {
    max_connections = "200"
    log_statement   = "ddl"
    work_mem        = "4096"
  }

  tags = {
    Environment = "final-project"
    Project     = "goit-devops-cicd"
  }

  depends_on = [module.vpc]
}

# This step connects your local kubectl/helm to the EKS cluster after AWS creates it.
# It replaces the fragile two-step provider approach from lesson-db-module.
resource "null_resource" "configure_kubeconfig" {
  triggers = {
    cluster_name     = module.eks.eks_cluster_name
    cluster_endpoint = module.eks.eks_cluster_endpoint
    region           = var.aws_region
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-lc"]
    command     = <<EOT
set -euo pipefail
aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.eks_cluster_name}

for i in {1..60}; do
  NODE_COUNT=$(kubectl get nodes --no-headers 2>/dev/null | wc -l | tr -d ' ')
  if [ "$NODE_COUNT" != "0" ]; then
    break
  fi
  echo "Waiting for EKS worker nodes..."
  sleep 10
done

kubectl wait --for=condition=Ready nodes --all --timeout=10m
EOT
  }

  depends_on = [module.eks]
}

module "jenkins" {
  source            = "./modules/jenkins"
  cluster_name      = module.eks.eks_cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url

  depends_on = [null_resource.configure_kubeconfig]
}

module "argo_cd" {
  source          = "./modules/argo_cd"
  namespace       = "argocd"
  chart_version   = "5.46.4"
  repo_url        = var.github_repo_url
  target_revision = var.github_branch
  app_chart_path  = "final-project/charts/django-app"
  app_namespace   = "default"

  image_repository = module.ecr.repository_url
  db_host          = var.use_aurora ? module.rds.aurora_cluster_endpoint : module.rds.rds_endpoint
  db_name          = var.db_name
  db_username      = var.db_username
  db_password      = var.db_password

  depends_on = [
    null_resource.configure_kubeconfig,
    module.rds,
    module.ecr
  ]
}

module "monitoring" {
  source = "./modules/monitoring"

  depends_on = [null_resource.configure_kubeconfig]
}
