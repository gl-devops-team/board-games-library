# Terraform Dev Environment

This is the root module for the `dev` environment. All application infrastructure
for the dev environment is provisioned from this directory — VPC, ECR, EKS and any
future modules are added here as `module` blocks.

## Purpose

`environments/dev/` is the single entry point for all `terraform init/plan/apply`
operations against the dev environment. Individual modules in `modules/` are
definitions only — they have no backend and cannot be run directly.

## Structure

```
environments/dev/
├── main.tf       - module calls (networking, ecr, and future: eks...)
├── providers.tf  - AWS provider for eu-central-1
└── versions.tf   - Terraform version constraints + S3 backend configuration
```

## Terraform state

State is stored in S3:

```
s3://boardgames-dev-tfstate/env/dev/terraform.tfstate
```

All module resources accumulate in the same state file — Terraform handles dependency
ordering automatically based on output references between modules.

## Prerequisites

Before running `terraform apply` for the first time, the following must exist:

| Step | What | How |
|---|---|---|
| 1 | S3 state bucket + KMS key | `terraform apply` in `core/` |
| 2 | Core IAM role for GitHub Actions | `core/bootstrap/apply.sh` |
| 3 | Platform IAM role for GitHub Actions | `platform/bootstrap/apply.sh` |
| 4 | Platform managed policy | `terraform apply` in `platform/` |

## Usage

### Local run

```bash
cd infra/terraform/environments/dev
export AWS_PROFILE=boardgames-dev-admin
terraform init
terraform plan
terraform apply
```

### GitHub Actions

The `terraform_env_dev.yml` workflow runs automatically on push. Apply requires
manual trigger with `apply: true` input.

The workflow uses the `github-actions-boardgames-dev-platform` role (via OIDC).

## Cost note

NAT Gateways (~$32/month each × 2) are the main cost driver in this environment.
ECR repositories have no base cost — you pay only for storage and data transfer.
Run `terraform destroy` when the environment is not needed to avoid ongoing charges.
