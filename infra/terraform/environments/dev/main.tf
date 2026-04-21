module "networking" {
  source = "../../modules/networking"

  project     = "boardgames"
  environment = "dev"
}
