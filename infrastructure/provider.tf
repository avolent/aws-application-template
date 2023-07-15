provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Deployed_from = var.git_repo
      Environment   = var.environment
      Project       = var.project_name
    }
  }
}