output "repository_url" {
  value = data.aws_ecr_repository.main.repository_url
}

output "repository_name" {
  description = "ECR repository name"
  value       = data.aws_ecr_repository.main.name
  
}