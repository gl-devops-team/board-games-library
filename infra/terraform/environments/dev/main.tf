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
