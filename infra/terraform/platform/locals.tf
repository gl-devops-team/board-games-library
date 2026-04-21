locals {
  name_prefix = "${var.project}-${var.environment}"

  tfstate_key = "platform/${var.environment}/terraform.tfstate"

  github_platform_role_name = "github-actions-${local.name_prefix}-${var.component}"

  common_tags = {
    Project     = var.project
    Environment = var.environment
    Component   = var.component
    ManagedBy   = "Terraform"
  }
}
