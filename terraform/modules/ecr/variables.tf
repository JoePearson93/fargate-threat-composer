variable "repository_name" {
  description = "Name of ECR repository"
  type        = string
}


variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "The environment name (dev, staging, prod)"
  type        = string
}
