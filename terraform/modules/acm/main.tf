terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5"
    }
  }
}

data "aws_ssm_parameter" "cloudflare_zone_id" {
  name = "/fargate-threat-composer/cloudflare_zone_id"
}

data "aws_ssm_parameter" "cloudflare_api_token" {
  name = "/fargate-threat-composer/cloudflare_api_token"
}


resource "aws_acm_certificate" "cert" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  tags = {
    Name        = "${var.project_name}-acm"
    environment = var.environment
  }
}

resource "cloudflare_dns_record" "acm_validation" {
  zone_id = data.aws_ssm_parameter.cloudflare_zone_id.value
  name    = tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_type
  content = tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_value
  ttl     = 300
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [cloudflare_dns_record.acm_validation.name]
}

resource "cloudflare_dns_record" "main_dns_record" {
  zone_id = data.aws_ssm_parameter.cloudflare_zone_id.value
  name    = var.domain_name
  ttl     = 300
  content = var.alb_dns_name
  type    = "CNAME"
}