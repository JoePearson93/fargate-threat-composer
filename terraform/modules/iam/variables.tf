variable "fargate_task_execution_role" {
  description = "ECS Task Execution Role"
  type        = string
}

variable "fargate_task_service_role" {
  description = "ECS Task Service Role."
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

