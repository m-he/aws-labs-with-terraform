#!/usr/bin/env bash
set -euo pipefail

# Auto-generate backend.hcl with account-regional bucket name and init terraform
# Usage: ./init_backend.sh [region]
# Example: ./init_backend.sh us-east-1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION=${1:-$(aws configure get region 2>/dev/null || echo "us-east-1")}
BUCKET="terraform-state-${AWS_ACCOUNT_ID}-${REGION}-an"

echo "Initializing Terraform with S3 Account Regional backend"
echo "  Bucket: ${BUCKET}"
echo "  Region: ${REGION}"

terraform init \
  -backend-config="bucket=${BUCKET}" \
  -backend-config="region=${REGION}"
