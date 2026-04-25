module "networking" {
  source = "../../modules/networking"

  project     = "boardgames"
  environment = "dev"
}

module "ecr" {
  source = "../../modules/ecr"

  project     = "boardgames"
  environment = "dev"
}

module "eks" {
  source = "../../modules/eks"

  project     = "boardgames"
  environment = "dev"

  vpc_id              = module.networking.vpc_id
  private_subnet_ids  = module.networking.private_subnet_ids
  public_subnet_ids   = module.networking.public_subnet_ids
  ecr_repository_arns = values(module.ecr.repository_arns)
}

module "secrets" {
  source = "../../modules/secrets"

  project     = "boardgames"
  environment = "dev"

  db_user        = var.db_user
  db_password    = var.db_password
  db_name        = var.db_name
  app_secret_key = var.app_secret_key
}
