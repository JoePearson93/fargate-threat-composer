variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}
variable "alb_dns_name" {
  description = "Name of Application Load Balancer"
  type        = string
}

variable "vpc_id"{
  description = "ID of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "Pubic subnet IDs for the ALB"
  type        = list(string)
}

variable "alb_security_group_ids" {
  description = "Security group IDs for the ALB"
  type        = list(string)
}

variable "environment" {
  description = "The environment name (dev, staging, prod)"
  type        = string
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
}

variable "certificate_arn" {
  description = "ACM certificate ARN"
  type        = string
}