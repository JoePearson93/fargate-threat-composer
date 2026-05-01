module "vpc" {
  source = "./modules/vpc"
  
    vpc_cidr             = var.vpc_cidr
    public_subnet_cidrs  = var.public_subnet_cidrs
    private_subnet_cidrs = var.private_subnet_cidrs
    project_name         = var.project_name
    environment          = var.environment
}

module "security_groups" {
  source                  = "./modules/security-groups"
  
    vpc_id                  = module.vpc.vpc_id
    ecs_port                = 8080
    project_name            = var.project_name
    environment             = var.environment
}

module "ecr" {
  source             = "./modules/ecr"
  
    repository_name    = var.repository_name
    project_name       = var.project_name
    environment        = var.environment

}

module "acm"{
  source                  = "./modules/acm"

    domain_name           = var.domain_name
    project_name          = var.project_name
    environment           = var.environment
}

module "alb" {
  source                  = "./modules/alb"
  
    alb_name                = var.alb_name
    vpc_id                  = module.vpc.vpc_id
    public_subnet_ids       = module.vpc.public_subnet_ids
    alb_security_group_ids  = [module.security_groups.alb_sg_id]
    project_name            = var.project_name
    environment             = var.environment
    container_port          = var.container_port
}

