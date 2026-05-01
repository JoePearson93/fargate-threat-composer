variable "domain_name" {
  description = "DNS name"
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