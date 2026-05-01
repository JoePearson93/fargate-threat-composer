resource "aws_acm_certificate" "cert" {
  domain_name       = var.domain_name
  validation_method = "DNS"

    tags = {
    Name = "${var.project_name}-acm"
    environment = var.environment
  }
}
