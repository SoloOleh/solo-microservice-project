variable "aws_region" {
  description = "AWS region where all resources will be created."
  type        = string
  default     = "us-west-2"
}

variable "aws_account_id" {
  description = "AWS account ID. Used in documentation and Jenkins examples."
  type        = string
  default     = "731732766187"
}

variable "github_repo_url" {
  description = "GitHub repository URL used by Argo CD."
  type        = string
  default     = "https://github.com/SoloOleh/goit-devops-cicd.git"
}

variable "github_branch" {
  description = "Git branch used by Argo CD and Jenkins."
  type        = string
  default     = "final-project"
}

variable "s3_backend_bucket" {
  description = "S3 bucket name for Terraform state storage."
  type        = string
  default     = "terraform-state-bucket-solo"
}

variable "dynamodb_table" {
  description = "DynamoDB table name for Terraform state locking."
  type        = string
  default     = "terraform-locks"
}

variable "ecr_repo_name" {
  description = "ECR repository name for the Django Docker image."
  type        = string
  default     = "django-app"
}

variable "eks_cluster_name" {
  description = "EKS cluster name."
  type        = string
  default     = "eks-cluster-demo"
}

variable "eks_node_instance_type" {
  description = "EC2 instance type for EKS worker nodes."
  type        = string
  default     = "t3.small"
}

variable "eks_desired_size" {
  description = "Desired number of EKS worker nodes."
  type        = number
  default     = 2
}

variable "eks_min_size" {
  description = "Minimum number of EKS worker nodes."
  type        = number
  default     = 2
}

variable "eks_max_size" {
  description = "Maximum number of EKS worker nodes."
  type        = number
  default     = 3
}

variable "vpc_cidr_block" {
  description = "Main CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "CIDR blocks for public subnets."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnets" {
  description = "CIDR blocks for private subnets."
  type        = list(string)
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "availability_zones" {
  description = "Availability zones for the subnets."
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "use_aurora" {
  description = "false = standard RDS instance, true = Aurora PostgreSQL cluster."
  type        = bool
  default     = false
}

variable "db_name" {
  description = "Initial database name."
  type        = string
  default     = "goitdb"
}

variable "db_username" {
  description = "Database master username."
  type        = string
  default     = "postgres"
}

variable "db_password" {
  description = "Database master password. For homework it has a default; in real projects use secrets."
  type        = string
  sensitive   = true
  default     = "admin123AWS23"
}

variable "db_instance_class" {
  description = "RDS/Aurora instance class."
  type        = string
  default     = "db.t3.micro"
}
