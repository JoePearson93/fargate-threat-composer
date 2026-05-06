variable "cluster_name"{
  description = "Name of ecs cluster"
  type        = string
}

  variable "ecr_repository_url" {
    description = "URL for ecr repository"
    type        = string
  }

variable "service_name" {
  description = "ECS service name"
  type        = string
}

variable "fargate_cpu" {
    description = "Amount of Fargate CPU"
    type        = string
}

variable "fargate_memory" {
    description = "Amount of Fargate memory"
    type        = string
}

variable "aws_region" {
  description = "aws region where the resouces will be created"
  type        = string
}

variable "cw_log_group" {
  description = "CloudWatch log group name for ECS container logs"
  type        = string
}

variable "cw_log_stream"{
  description = "CloudWatch log stream prefix for ECS container logs"
  type        = string
}

variable "task_role_arn" {
  description = "ARN of the ECS task role"
  type        = string
}

variable "execution_role_arn" {
  description = "ARN of the ECS task execution role"
  type        = string
}

variable "container_port" {
  description = "Container port"
  type        = number
}

variable "task_count" {
  description = "define how many ECS tasks running"
  type        = number
}

variable "private_subnet_ids" {
  description = "Subnet private IDs"
  type       = list(string)
}

variable "ecs_security_group_id" {
  description = "Security group for ECS task"
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "target_group_arn"{
  description = " ARN for ECS ALB target group"
  type        = string
}

variable "environment" {
  description = "The environment name (dev, staging, prod)"
  type        = string
}