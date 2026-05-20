# Deployment Guide

Full step by step instructions for deploying the Threat Composer application to AWS ECS Fargate.

> This project uses S3 native state locking (`use_lockfile = true`) — no DynamoDB required.

## Deployment Workflow


**Infrastructure changes (Terraform):**
```
Code change → PR → terraform plan → Review → Merge → terraform apply
```

**Application changes (CI/CD):**
```
Code change → PR → CI checks → Merge → Pipeline builds and pushes image → ECS rolling deployment
```

Terraform uses `ignore_changes` on the ECS task definition and container definitions so infrastructure and application deployments are fully decoupled.

---

## Step 1 — Bootstrap (one time, run locally)

The bootstrap provisions the GitHub Actions OIDC provider and IAM role. This is the only step that requires running Terraform locally.

```sh
cd bootstrap
terraform init
terraform apply
```

Note the `role_arn` output — you will need this in the next step.

---

## Step 2 — Configure GitHub Actions

### Repository Secret

| Secret | Value |
|---|---|
| `AWS_OIDC_ARN` | `role_arn` from bootstrap output |

### Repository Variables

| Variable | Example |
|---|---|
| `AWS_REGION` | `eu-west-2` |
| `ECR_REPOSITORY` | `fargate-threat-composer` |
| `ECS_CLUSTER` | `tm-cluster` |
| `ECS_SERVICE` | `fargate-threat-composer-ecs-service` |
| `CONTAINER_NAME` | `fargate-threat-composer` |

---

## Step 3 — Deploy

Everything from here is handled by the pipelines.

**Deploy infrastructure:**
Trigger the Terraform Deploy workflow from the GitHub Actions tab.

**Deploy application:**
Push to `main` — the CI pipeline builds, scans and deploys automatically.

---

## Teardown

Trigger the Terraform Destroy workflow from the GitHub Actions tab.

To destroy bootstrap resources:

```sh
cd bootstrap
terraform destroy
```

---

## Common Errors

**ECS task stuck in PROVISIONING**
Check the ECS task security group allows inbound on port 8080 from the ALB security group only.

**ACM certificate stuck in Pending validation**
Check the Route53 validation CNAME record was created correctly in your hosted zone.

**Target group health checks failing**
Verify the health check path returns a 200-399 response and the container is listening on port 8080.

**Grype scan fails**
Review the vulnerability report and remediate or add exceptions for accepted risks in your Grype configuration.
