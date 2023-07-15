variable "aws_region" {
  type        = string
  description = "The default aws region"
  default     = "ap-southeast-2"
}

variable "git_repo" {
  type        = string
  description = "The current git repository"
}

variable "project_name" {
  type        = string
  description = "Your project name, it will be used for naming resources"
  default     = "application_name"
}

variable "environment" {
  type        = string
  description = "Deployment Environment"
  default     = "dev"
}