locals {
  name_prefix = "${var.project}-${var.environment}"

  tfstate_bucket_name = "${local.name_prefix}-tfstate"
  tfstate_key         = "core/${var.environment}/terraform.tfstate"

  github_core_role_name = "github-actions-${local.name_prefix}-${var.component}"

  common_tags = {
    Project     = var.project
    Environment = var.environment
    Component   = var.component
    ManagedBy   = "Terraform"
  }
}