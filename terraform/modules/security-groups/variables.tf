variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC to deploy security groups into"
  type        = string
}

variable "ecs_port" {
  description = "port for application container to call"
  type        = number
}

variable "environment" {
  description = "The environment name (dev, staging, prod)"
  type        = string
}

