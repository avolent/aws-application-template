variable "aws_region" {
  type        = string
  description = "The default aws region"
  default     = "ap-southeast-2"
}

variable "git_repo" {
  type        = string
  description = "The current git repository"
}

variable "app_name" {
  type        = string
  description = "Your application name, it will be used for naming resources"
  default     = "application"
}

variable "app_env" {
  type        = string
  description = "Deployment Environment"
}