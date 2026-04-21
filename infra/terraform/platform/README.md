# Terraform Platform Infrastructure

This directory contains the Terraform configuration responsible for provisioning
the platform IAM role used by GitHub Actions to manage application infrastructure
(VPC, EKS, ECR, CloudWatch and other future modules).

## Purpose

The `platform` layer creates and manages:

- IAM managed policy granting the platform GitHub Actions role access to Terraform state
- Policy attachment to the `github-actions-boardgames-dev-platform` role

This layer is intentionally minimal at this stage. Permissions will be extended
as new infrastructure modules are added (networking, EKS, ECR, CloudWatch).

## Why this exists

The `core` module manages Terraform state backend. Everything above it — VPC, EKS,
ECR, CloudWatch — is provisioned by a separate `platform` role. This separation ensures
that a failure or misconfiguration in platform workflows cannot affect the state backend.

See `infra/terraform/core/` for the bootstrap problem explanation and two-phase setup pattern.

## Structure

```
platform/
├── main.tf                                     - IAM policy and role attachment
├── variables.tf                                - input variables
├── locals.tf                                   - naming and tagging logic
├── outputs.tf                                  - exposed outputs
├── providers.tf                                - AWS provider configuration
├── versions.tf                                 - Terraform and provider constraints
├── policies/
│   └── tfstate-access.json.tftpl               - least-privilege tfstate policy (platform + core read)
└── bootstrap/
    ├── platform-bootstrap-policy.json.tftpl    - permissions for Terraform to manage this module
    ├── platform-assume-role-policy.json.tftpl  - OIDC trust policy (who can assume the role)
    └── apply.sh                                - one-time bootstrap script
```

## How terraform_remote_state works here

This module reads outputs from the `core` module using `data "terraform_remote_state"`:

```hcl
data "terraform_remote_state" "core" {
  backend = "s3"
  config = {
    bucket = "boardgames-dev-tfstate"
    key    = "core/dev/terraform.tfstate"
    region = "eu-central-1"
  }
}
```

Instead of hardcoding the S3 bucket ARN, the platform module reads it directly from
core's Terraform state. This creates an explicit dependency between modules — if core
state does not exist in S3, platform `plan` will fail. The platform role therefore needs
`s3:GetObject` on the core state file, included in both `platform-bootstrap-policy.json.tftpl`
and `policies/tfstate-access.json.tftpl`.

This is why core state must be migrated to S3 before platform can run (see core README,
Bootstrap section). Once core state is in S3, platform works without any manual steps.

In production, SSM Parameter Store is a common alternative to `terraform_remote_state`
as it avoids tight coupling between modules — core writes outputs to SSM, other modules
read from SSM without knowing where the state lives.

## Local AWS credentials setup

See `infra/terraform/core/README.md` for AWS CLI v2 installation and SSO profile setup.
The same profile (`boardgames-dev-admin`) is used for all Terraform modules.

## Bootstrap

**Phase 0 — Bootstrap (run once, manually, with admin credentials):**

```bash
export AWS_PROFILE=boardgames-dev-admin
./bootstrap/apply.sh
```

This script uses `envsubst` to render the JSON templates and applies them via AWS CLI:
- creates the `github-actions-boardgames-dev-platform` IAM role if it does not exist
- if the role already exists, updates its assume role policy (idempotent — safe to re-run)
- attaches `boardgames-dev-platform-bootstrap` inline policy (permissions to manage this module's resources)

The script is safe to re-run at any time — role creation is skipped if the role already exists,
and both `update-assume-role-policy` and `put-role-policy` are idempotent AWS CLI operations.

**Phase 1 — Terraform (runs automatically via GitHub Actions after every push):**

```bash
terraform init
terraform plan
terraform apply
```

The `terraform_platform.yml` workflow handles this automatically.

## Usage

### Local run

```bash
export AWS_PROFILE=boardgames-dev-admin
terraform init
terraform plan
terraform apply
```

### Important notes

- Do NOT store application infrastructure here (VPC, EKS, ECR etc.) — those go in `modules/` and `environments/`
- Bootstrap policy will be extended as new modules are added
- `bootstrap/` files are not referenced by Terraform — they exist for documentation and re-provisioning

## Naming

Current naming convention:

- project: `boardgames`
- environment: `dev`

Generated resources:

- IAM policy: `boardgames-dev-github-platform-tfstate-access`
