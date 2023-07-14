variable "project_name" {
  type        = string
  description = "Your project name, it will be used for naming resources"
  default     = "application_name"
}

variable "aws_region" {
  type        = string
  description = "The default aws region"
  default     = "ap-southeast-2"
}

variable "environment" {
  type        = string
  description = "Deployment Environment"
  default     = "dev"
}