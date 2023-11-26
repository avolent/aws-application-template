provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      repository  = var.git_repo
      environment = var.app_env
      project     = var.app_name
    }
  }
}