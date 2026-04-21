locals {
  name_prefix = "${var.project}-${var.environment}"

  vpc_cidr = "10.0.0.0/16"

  azs                  = ["${var.aws_region}a", "${var.aws_region}b"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]

  common_tags = {
    Project     = var.project
    Environment = var.environment
    Component   = var.component
    ManagedBy   = "Terraform"
  }
}
