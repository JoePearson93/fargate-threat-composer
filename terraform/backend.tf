 terraform {
   backend "s3" {
     bucket       = "fargate-threat-composer"
     key          = "terraform.tfstate"
     region       = "eu-west-2"
     encrypt      = true
     use_lockfile = true
   }
 }