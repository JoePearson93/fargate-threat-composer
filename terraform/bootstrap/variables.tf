variable "aws_region" {
  description = "aws region where the resouces will be created"
  type        = string
  default     = "eu-west-2"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "fargate-threat-composer"
}

variable "environment" {
  description = "The environment name (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "allowed_subjects" {
  description = <<-EOT
    List of GitHub OIDC subject claims allowed to assume the role.
    Format: repo:<org>/<repo>:ref:refs/heads/<branch>
            repo:<org>/<repo>:pull_request

    Examples:
      - "repo:CoderCo/my-app:ref:refs/heads/main"     -> only main branch
      - "repo:CoderCo/my-app:pull_request"             -> PR workflows
      - "repo:CoderCo/my-app:*"                        -> any branch (less secure)
  EOT
  type        = list(string)
  default     = []
}