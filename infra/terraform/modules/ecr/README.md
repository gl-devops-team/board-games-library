# Terraform ECR Module

This directory contains the reusable Terraform module for provisioning AWS Elastic
Container Registry repositories. It is not a root module — it is called from
`environments/dev/` and does not define a backend or run `terraform init` directly.

## Purpose

The `ecr` module creates private container image repositories for the application's
Docker images. ECR is provisioned before EKS — nodes need to pull images during
deployment. Using ECR over Docker Hub eliminates rate limiting, keeps images in the
same AWS account/region (faster pulls, no egress costs), and integrates natively
with IAM for access control.

## Structure

```
modules/ecr/
├── main.tf       - ECR repositories, lifecycle policies, repository policies
├── locals.tf     - name prefix, common tags
├── variables.tf  - input variables (aws_region, project, environment, component, image_names, max_image_count)
├── outputs.tf    - repository_urls, repository_arns
├── providers.tf  - AWS provider with default tags
└── versions.tf   - Terraform and provider version constraints (no backend block)
```

## Resources created

| Resource | Count | Notes |
|---|---|---|
| `aws_ecr_repository` | 2 | backend, frontend — immutable tags, scan on push |
| `aws_ecr_lifecycle_policy` | 2 | Expire untagged after 1 day, keep last N tagged |
| `aws_ecr_repository_policy` | 2 | Scoped to `boardgames-dev-*` IAM roles |

Total: **6 resources**

## Lifecycle policy

Two rules per repository:

1. **Untagged images** — expired after 1 day (build artifacts without a release tag)
2. **Tagged images** — keep the last `max_image_count` (default 10) images prefixed with `v`

## Repository policy

Access is scoped to IAM roles matching `boardgames-dev-*` in the same account.
This covers the platform GitHub Actions role and future EKS node roles without
granting blanket access.

## Usage

This module is not run directly. It is called from `environments/dev/main.tf`:

```hcl
module "ecr" {
  source      = "../../modules/ecr"
  project     = "boardgames"
  environment = "dev"
}
```

Run Terraform from `environments/dev/`, not from this directory.

## Outputs

Downstream modules (EKS, CI/CD) consume outputs from this module:

- `repository_urls` — map of image name → ECR URL (used in Kubernetes manifests and docker push)
- `repository_arns` — map of image name → ARN (used in IAM policies)
