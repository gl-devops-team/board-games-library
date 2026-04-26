#!/usr/bin/env bash
# Run once with admin AWS credentials to bootstrap the platform IAM role.
# Usage:
#   export AWS_PROFILE=boardgames-dev-admin
#   ./bootstrap/apply.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

account_id=$(aws sts get-caller-identity --query Account --output text)
bucket_name="boardgames-dev-tfstate"
environment="dev"
platform_role_name="github-actions-boardgames-dev-platform"
tfstate_policy_name="boardgames-dev-github-platform-tfstate-access"
github_repo="gl-devops-team/board-games-library"

export account_id bucket_name environment platform_role_name tfstate_policy_name github_repo

envsubst < "${SCRIPT_DIR}/platform-assume-role-policy.json.tftpl" > /tmp/assume-role-policy.json
role_description="GitHub Actions OIDC role for Terraform platform module - app infrastructure"

if aws iam get-role --role-name "${platform_role_name}" > /dev/null 2>&1; then
  echo "Role ${platform_role_name} already exists, skipping creation"
  echo "Updating assume role policy for role: ${platform_role_name}"
  aws iam update-assume-role-policy \
    --role-name "${platform_role_name}" \
    --policy-document file:///tmp/assume-role-policy.json
  aws iam update-role \
    --role-name "${platform_role_name}" \
    --description "${role_description}"
else
  echo "Creating platform IAM role: ${platform_role_name}"
  aws iam create-role \
    --role-name "${platform_role_name}" \
    --description "${role_description}" \
    --assume-role-policy-document file:///tmp/assume-role-policy.json
fi

echo "Removing existing inline policies from role: ${platform_role_name}"
existing_policies=$(aws iam list-role-policies \
  --role-name "${platform_role_name}" \
  --query 'PolicyNames' --output text)
for policy_name in ${existing_policies}; do
  echo "  Deleting inline policy: ${policy_name}"
  aws iam delete-role-policy \
    --role-name "${platform_role_name}" \
    --policy-name "${policy_name}"
done

compact_json() {
  python3 -c "import json,sys; print(json.dumps(json.load(sys.stdin)))"
}

echo "Applying bootstrap policies to role: ${platform_role_name}"
envsubst < "${SCRIPT_DIR}/platform-bootstrap-policy.json.tftpl" \
  | compact_json > /tmp/bootstrap-policy-1.json
aws iam put-role-policy \
  --role-name "${platform_role_name}" \
  --policy-name "boardgames-dev-platform-bootstrap" \
  --policy-document file:///tmp/bootstrap-policy-1.json

envsubst < "${SCRIPT_DIR}/platform-bootstrap-policy-2.json.tftpl" \
  | compact_json > /tmp/bootstrap-policy-2.json
aws iam put-role-policy \
  --role-name "${platform_role_name}" \
  --policy-name "boardgames-dev-platform-bootstrap-2" \
  --policy-document file:///tmp/bootstrap-policy-2.json

echo "Bootstrap complete. Run 'terraform apply' in infra/terraform/platform/ next."
