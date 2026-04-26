locals {
  name_prefix = "${var.project}-${var.environment}"

  common_tags = {
    Project     = var.project
    Environment = var.environment
    Component   = var.component
    ManagedBy   = "Terraform"
  }

  db_url = "postgresql://${var.db_user}:${var.db_password}@db-service:5432/${var.db_name}"
}
