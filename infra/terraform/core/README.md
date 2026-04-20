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
- `main.tf` – AWS resources (S3 bucket and IAM policy)
- `outputs.tf` – exposed outputs
- `policies/tfstate-access.json.tftpl` – least-privilege IAM policy for the GitHub Actions core role
- `bootstrap/core-bootstrap-policy.json.tftpl` – broader IAM policy applied once to allow Terraform to bootstrap itself
- `bootstrap/core-assume-role-policy.json.tftpl` – assume role policy defining who can assume the core role (GitHub Actions via OIDC)
- `bootstrap/apply.sh` – one-time script to apply bootstrap policies via AWS CLI

## Local AWS credentials setup (first time)

Access to AWS is managed through IAM Identity Center (SSO). AWS CLI v2 is required — v1 does not support SSO.

### Install AWS CLI v2 (Ubuntu / WSL2)

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
unzip /tmp/awscliv2.zip -d /tmp
sudo /tmp/aws/install
aws --version  # expected: aws-cli/2.x.x
```

### Configure SSO profile

```bash
aws configure sso
```

When prompted:

| Field | Value |
|---|---|
| SSO session name | `boardgames` |
| SSO start URL | `https://d-9967442e26.awsapps.com/start` |
| SSO region | `eu-central-1` |
| SSO registration scopes | *(press Enter — keep default)* |
| CLI default client Region | `eu-central-1` |
| CLI default output format | `json` |
| CLI profile name | `boardgames-dev-admin` |

A browser window will open — approve the login, then return to the terminal and select:
- account: `boardgames-dev`
- permission set: `AdministratorAccess`

### Verify

```bash
aws sts get-caller-identity --profile boardgames-dev-admin
# expected: Account "595324333130", UserId ending with your SSO username
```

### Login (each session)

SSO tokens expire. Re-authenticate before running any AWS commands:

```bash
aws sso login --profile boardgames-dev-admin
```

To avoid passing `--profile` to every command, export the profile for the current terminal session:

```bash
export AWS_PROFILE=boardgames-dev-admin
```

After that, `terraform plan`, `terraform apply`, and `aws` commands will use the profile automatically.
The export is active until the terminal is closed.

---

## Bootstrap

This module has a chicken-and-egg problem: Terraform needs IAM permissions to create resources,
but those permissions must exist before Terraform runs for the first time.

The solution is a two-phase setup:

**Phase 0 — Bootstrap (run once, manually, with admin credentials):**

The `apply.sh` script exists to solve a circular dependency: Terraform needs IAM permissions
to create the S3 bucket and IAM policy, but those permissions cannot be managed by Terraform
itself before the backend exists. The script applies them once via AWS CLI using your personal
admin credentials, after which Terraform takes over and manages everything else.

```bash
aws sso login --profile boardgames-dev-admin
AWS_PROFILE=boardgames-dev-admin ./bootstrap/apply.sh
```

This script uses `envsubst` to render the JSON templates and applies them via AWS CLI:
- creates the `github-actions-boardgames-dev-core` IAM role if it does not exist
- if the role already exists, updates its assume role policy (idempotent — safe to re-run)
- attaches `CoreBootstrap` inline policy to the core role (permissions to manage S3 + IAM)

The script is safe to re-run at any time — role creation is skipped if the role already exists,
and both `update-assume-role-policy` and `put-role-policy` are idempotent AWS CLI operations.

**Phase 1 — Terraform (runs automatically via GitHub Actions after every push):**

```bash
terraform init
terraform plan
terraform apply
```

The `terraform_core.yml` workflow handles this automatically. The core role assumed by GitHub Actions
has only the permissions defined in `policies/tfstate-access.json.tftpl` — no admin access.

> **Note:** If the role `github-actions-boardgames-dev-core` already exists in AWS,
> Phase 1 has already been completed and does not need to be repeated.

## Usage

### Local run (requires AWS credentials with access to the core role)

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
- `bootstrap/` files are not referenced by Terraform — they exist for documentation and re-provisioning

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
