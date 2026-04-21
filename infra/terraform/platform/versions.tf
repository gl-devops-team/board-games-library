terraform {
  required_version = ">=1.9.0, <2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket = "boardgames-dev-tfstate"
    key    = "platform/dev/terraform.tfstate"
    region = "eu-central-1"
  }
}
