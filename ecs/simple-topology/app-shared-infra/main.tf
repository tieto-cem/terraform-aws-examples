provider "aws" {
  region = "eu-west-1"
}

locals {
  env          = "${terraform.workspace}"
  app_env_name = "${var.application_name}-${local.env}"
}
