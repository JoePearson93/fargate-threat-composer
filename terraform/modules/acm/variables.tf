variable "domain_name" {
  description = "DNS name"
  type        = string
}

variable "alb_dns_name" {
  description = "Name of Application Load Balancer"
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