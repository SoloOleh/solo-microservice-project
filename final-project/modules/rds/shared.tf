locals {
  db_port    = contains(["mysql", "aurora-mysql"], var.use_aurora ? var.engine_cluster : var.engine) ? 3306 : 5432
  subnet_ids = var.publicly_accessible ? var.subnet_public_ids : var.subnet_private_ids
}

resource "aws_db_subnet_group" "default" {
  name       = "${var.name}-subnet-group"
  subnet_ids = local.subnet_ids
  tags       = var.tags
}

resource "aws_security_group" "rds" {
  name        = "${var.name}-sg"
  description = "Security group for RDS or Aurora"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = local.db_port
    to_port     = local.db_port
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}
