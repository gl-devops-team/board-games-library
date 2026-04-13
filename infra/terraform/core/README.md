# Terraform Core Infrastructure

This directory contains the Terraform configuration responsible for provisioning
the foundational AWS resources required to manage Terraform state remotely.

## Purpose

The `core` layer creates and manages:

- S3 bucket used to store Terraform remote state (`tfstate`)
- S3 bucket versioning for state recovery
- S3 public access block to prevent accidental exposure

This layer is intentionally minimal and should only contain resources required
to support Terraform itself.

## Why this exists

Terraform needs a persistent backend to safely:

- store infrastructure state
- detect changes between runs
- support team collaboration
- enable CI/CD workflows

Without remote state, each Terraform execution would rely on local state files,
which is not suitable for team workflows or GitHub Actions.

## Structure

This module includes:

- `versions.tf` – Terraform and provider version constraints
- `providers.tf` – AWS provider configuration
- `variables.tf` – input variables
- `locals.tf` – internal naming and tagging logic
- `main.tf` – AWS resources (S3 bucket and related config)
- `outputs.tf` – exposed outputs

## Usage

### Local run

```bash
terraform init
terraform plan
terraform apply
```

### Important notes

- Do NOT store application infrastructure here (EKS, ECR, CloudWatch, etc.)
- Do NOT destroy the state bucket unless intentionally decommissioning the project
- Bucket names in S3 must be globally unique
- Versioning is enabled to allow state recovery

## Naming

Current naming convention:

- project: `boardgames`
- environment: `dev`

Generated state bucket:

- `boardgames-dev-tfstate`

## Future improvements

Potential future enhancements:

- IAM policy for GitHub OIDC role access
- bucket encryption configuration
- stricter access controls
- lifecycle policies for object versions
