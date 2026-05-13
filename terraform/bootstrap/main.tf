terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6"
    }
  }

  backend "s3" {
    bucket         = "fargate-threat-composer"
    key            = "bootstrap/terraform.tfstate"
    region         = "eu-west-2"
    encrypt        = true
    use_lockfile   = true
 }
}

provider "aws" {
  region = var.aws_region
}

# Github OIDC Provider

data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]

tags = {
  Name        = "${var.project_name}-github-actions-oidc"
  environment = var.environment
  Purpose     = "GitHub Actions CI/CD"
 }
}
# 2. IAM Role for GitHub Actions

data "aws_iam_policy_document" "github_actions_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = var.allowed_subjects
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name               = "${var.project_name}-github-actions-role"
  assume_role_policy = data.aws_iam_policy_document.github_actions_trust.json

  tags = {
    Name        = "${var.project_name}-github-actions-oidc"
    environment = var.environment
    Purpose     = "GitHub Actions CI/CD for ECS"
  }
}

# 3. IAM Policy - Exact Permissions for the Pipeline

