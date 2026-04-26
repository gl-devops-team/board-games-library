locals {
  name_prefix = "${var.project}-${var.environment}"

  common_tags = {
    Project     = var.project
    Environment = var.environment
    Component   = var.component
    ManagedBy   = "Terraform"
  }
}
