terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6"
    }
  }

  backend "s3" {
    bucket       = "fargate-threat-composer"
    key          = "bootstrap/terraform.tfstate"
    region       = "eu-west-2"
    encrypt      = true
    use_lockfile = true
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

# IAM Policy - Exact Permissions for the Pipeline

data "aws_caller_identity" "current" {}


data "aws_iam_policy_document" "github_actions_permissions" {

  statement {
    sid    = "ECRAuth"
    effect = "Allow"
    actions = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid    = "ECRPushPull"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]
    resources = [
      "arn:aws:ecr:${var.aws_region}:${data.aws_caller_identity.current.account_id}:repository/${var.repository_name}"
    ]
  }

  statement {
    sid    = "TerraformReadAccess"
    effect = "Allow"
    actions = [
      "route53:ListHostedZones",
      "route53:GetHostedZone",
      "route53:ListResourceRecordSets",
      "route53:ListTagsForResource",
      "ecr:ListTagsForResource",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeVpcs",
      "ec2:DescribeSubnets",
      "ec2:DescribeRouteTables",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeInternetGateways"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "TerraformProvisioning"
    effect = "Allow"
    actions = [
      "ec2:*",
      "ecs:*",
      "ecr:*",
      "iam:*",
      "logs:*",
      "route53:*",
      "acm:*",
      "elasticloadbalancing:*"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "ECSDeployment"
    effect = "Allow"
    actions = [
      "ecs:UpdateService",
      "ecs:RegisterTaskDefinition",
      "ecs:DescribeServices",
      "ecs:DescribeTaskDefinition",
      "ecs:DescribeTasks",
      "ecs:ListTasks"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "PassRole"
    effect = "Allow"
    actions = ["iam:PassRole"]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.ecs_task_execution_role_name}",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.ecs_task_role_name}"
    ]
  }

  statement {
    sid    = "CloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:DescribeLogGroups"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "S3StateObjects"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = ["arn:aws:s3:::fargate-threat-composer/*"]
  }

  statement {
    sid    = "S3StateBucket"
    effect = "Allow"
    actions = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::fargate-threat-composer"]
  }

}

resource "aws_iam_policy" "github_actions" {
  name   = "${var.project_name}-github-actions-policy"
  policy = data.aws_iam_policy_document.github_actions_permissions.json
}

resource "aws_iam_role_policy_attachment" "github_actions" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions.arn
}
