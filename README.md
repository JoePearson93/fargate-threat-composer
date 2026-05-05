Threat Composer — AWS ECS Fargate Infrastructure

A containerised application deployed on AWS using ECS Fargate, provisioned end to end with Terraform following infrastructure as code best practices.

Project Overview
This project demonstrates a production-grade AWS infrastructure deployment for a containerised application. The infrastructure was first built manually via the AWS console (ClickOps) to develop a solid understanding of how each component works, then fully recreated using Terraform with a modular structure following the DRY principle.

Architecture
Traffic Flow:
Internet → Route53 → ALB (public subnets) → ECS Fargate Tasks (private subnets) → NAT Gateway (outbound only)

Key design decisions:

ECS tasks run in private subnets — not directly accessible from the internet
All inbound traffic routes through the Application Load Balancer
NAT Gateway handles outbound traffic from private subnets
HTTPS enforced via ACM certificate — HTTP redirects to HTTPS
Container runs on port 8080, ALB handles SSL termination


Architecture diagram coming soon

Infrastructure Components

Component                   Details
VPC                         Custom VPC with public and private subnets across 2 AZs
Subnets                     2 public subnets (ALB, NAT Gateway), 2 private subnets (ECS tasks)
Internet Gateway            Public internet access for ALB
NAT Gateway                 Outbound internet access for ECS tasks in private subnets
ALB                         Application Load Balancer with HTTP → HTTPS redirect
ACM                         SSL certificate for HTTPS
ECS Fargate                 Containerised app, no EC2 instances to manage 
ECR                         Docker image repository      
IAM                         ECS task execution role and task service role
S3 + DynnaoDB               Terraform remote state storage and state locking

Terraform Structure
.
├── backend.tf
├── main.tf
├── modules
│   ├── acm
│   ├── alb
│   ├── ecr
│   ├── iam
│   ├── security-groups
│   └── vpc
├── outputs.tf
├── provider.tf
├── terraform.tfvars
└── variables.tf

Each module is self contained with its own main.tf, variables.tf and outputs.tf.

Tech Stack

Cloud: AWS
IaC: Terraform
Compute: ECS Fargate
Containerisation: Docker
CI/CD: GitHub Actions (coming soon)
DNS: Route53
Language: Node.js / port 8080


Getting Started

Setup instructions coming soon

This project is part of an ongoing hands-on DevOps curriculum. Architecture diagrams and full documentation will be added on completion.