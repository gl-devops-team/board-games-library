#!/usr/bin/env bash
# Run once with admin AWS credentials to bootstrap the core IAM role.
# Usage:
#   export AWS_PROFILE=boardgames-dev-admin
#   ./bootstrap/apply.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
BUCKET_NAME="boardgames-dev-tfstate"
CORE_ROLE_NAME="github-actions-boardgames-dev-core"
TFSTATE_POLICY_NAME="boardgames-dev-github-core-tfstate-access"
GITHUB_REPO="gl-devops-team/board-games-library"

export ACCOUNT_ID BUCKET_NAME CORE_ROLE_NAME TFSTATE_POLICY_NAME GITHUB_REPO

echo "Applying bootstrap policy to role: ${CORE_ROLE_NAME}"
envsubst < "${SCRIPT_DIR}/core-bootstrap-policy.json.tftpl" > /tmp/bootstrap-policy.json
aws iam put-role-policy \
  --role-name "${CORE_ROLE_NAME}" \
  --policy-name "CoreBootstrap" \
  --policy-document file:///tmp/bootstrap-policy.json

echo "Updating trust policy for role: ${CORE_ROLE_NAME}"
envsubst < "${SCRIPT_DIR}/core-assume-role-policy.json.tftpl" > /tmp/trust-policy.json
aws iam update-assume-role-policy \
  --role-name "${CORE_ROLE_NAME}" \
  --policy-document file:///tmp/trust-policy.json

echo "Bootstrap complete. Run 'terraform apply' in infra/terraform/core/ next."
