terraform {
  backend "s3" {
    bucket       = "fargate-threat-composer"
    key          = "terraform.tfstate"
    region       = var.aws_region
    encrypt      = true
    use_lockfile = true
  }
}