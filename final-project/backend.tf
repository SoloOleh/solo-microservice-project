# Important for beginners:
# Terraform cannot create an S3 bucket/DynamoDB table and use them as its own remote backend
# during the very first `terraform init` in one step.
#
# That is why this final project keeps the remote backend block commented by default.
# The first run is simple and works with local state:
#   terraform init
#   terraform apply
#
# After the S3 bucket and DynamoDB table are created, you may uncomment this block
# and migrate local state to S3:
#   terraform init -migrate-state
#
# terraform {
#   backend "s3" {
#     bucket         = "terraform-state-bucket-solo"
#     key            = "final-project/terraform.tfstate"
#     region         = "us-west-2"
#     dynamodb_table = "terraform-locks"
#     encrypt        = true
#   }
# }
