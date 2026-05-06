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
    container_port          = var.container_port
    project_name            = var.project_name
    environment             = var.environment
}

module "iam" {
  source             = "./modules/iam"

    project_name                = var.project_name
    environment                 = var.environment
    fargate_task_execution_role = var.fargate_task_execution_role
    fargate_task_service_role   = var.fargate_task_service_role
}

module "ecr" {
  source             = "./modules/ecr"
  
    repository_name    = var.repository_name
    project_name       = var.project_name
    environment        = var.environment

}

module "alb" {
  source                  = "./modules/alb"
  
    alb_dns_name            = data.aws_ssm_parameter.cloudflare_zone_id.value
    certificate_arn         = module.acm.certificate_arn
    vpc_id                  = module.vpc.vpc_id
    public_subnet_ids       = module.vpc.public_subnet_ids
    alb_security_group_ids  = [module.security_groups.alb_sg_id]
    project_name            = var.project_name
    environment             = var.environment
    container_port          = var.container_port
}

module "acm"{
  source                  = "./modules/acm"

    domain_name        = var.domain_name
    alb_dns_name       = module.alb.alb_dns_name
    project_name       = var.project_name
    environment        = var.environment
}

module "ecs" {
  source             = "./modules/ecs"
    
    cluster_name           = var.cluster_name
    ecr_repository_url     = var.ecr_repository_url
    service_name           = var.service_name
    fargate_cpu            = var.fargate_cpu
    fargate_memory         = var.fargate_memory
    aws_region             = var.aws_region
    cw_log_group           = var.cw_log_group
    cw_log_stream          = var.cw_log_stream
    task_role_arn          = module.iam.tasks_service_role
    execution_role_arn     = module.iam.tasks_execution_role
    task_count             = var.task_count
    container_port         = var.container_port
    private_subnet_ids     = module.vpc.private_subnet_ids
    ecs_security_group_id  = module.security_groups.ecs_sg_id
    target_group_arn       = module.alb.target_group_arn
    project_name           = var.project_name
    environment            = var.environment
}