#!/usr/bin/env bash
# Run once with admin AWS credentials to bootstrap the core IAM role.
# Usage:
#   export AWS_PROFILE=boardgames-dev-admin
#   ./bootstrap/apply.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

account_id=$(aws sts get-caller-identity --query Account --output text)
bucket_name="boardgames-dev-tfstate"
core_role_name="github-actions-boardgames-dev-core"
tfstate_policy_name="boardgames-dev-github-core-tfstate-access"
github_repo="gl-devops-team/board-games-library"

export account_id bucket_name core_role_name tfstate_policy_name github_repo

envsubst < "${SCRIPT_DIR}/core-assume-role-policy.json.tftpl" > /tmp/assume-role-policy.json
role_description="GitHub Actions OIDC role for Terraform core module - tfstate backend"

if aws iam get-role --role-name "${core_role_name}" > /dev/null 2>&1; then
  echo "Role ${core_role_name} already exists, skipping creation"
  echo "Updating assume role policy for role: ${core_role_name}"
  aws iam update-assume-role-policy \
    --role-name "${core_role_name}" \
    --policy-document file:///tmp/assume-role-policy.json
  aws iam update-role \
    --role-name "${core_role_name}" \
    --description "${role_description}"
else
  echo "Creating core IAM role: ${core_role_name}"
  aws iam create-role \
    --role-name "${core_role_name}" \
    --description "${role_description}" \
    --assume-role-policy-document file:///tmp/assume-role-policy.json
fi

echo "Applying bootstrap policy to role: ${core_role_name}"
envsubst < "${SCRIPT_DIR}/core-bootstrap-policy.json.tftpl" > /tmp/bootstrap-policy.json
aws iam put-role-policy \
  --role-name "${core_role_name}" \
  --policy-name "boardgames-dev-core-bootstrap" \
  --policy-document file:///tmp/bootstrap-policy.json

echo "Bootstrap complete. Run 'terraform apply' in infra/terraform/core/ next."
