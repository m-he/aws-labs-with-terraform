#!/usr/bin/env bash
set -euo pipefail

# Disable the AWS CLI pager so the script never pauses for interactive output.
export AWS_PAGER=""

ROLE_NAME="github-actions-oidc-admin"
REPO="m-he/aws-labs-with-terraform"
BRANCH_PATTERN="refs/heads/*"
OIDC_URL="token.actions.githubusercontent.com"
POLICY_ARN="arn:aws:iam::aws:policy/AdministratorAccess"

AWS_ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
OIDC_PROVIDER_ARN="arn:aws:iam::${AWS_ACCOUNT_ID}:oidc-provider/${OIDC_URL}"

if ! aws iam get-open-id-connect-provider \
  --open-id-connect-provider-arn "${OIDC_PROVIDER_ARN}" >/dev/null 2>&1; then
  aws iam create-open-id-connect-provider \
    --url "https://${OIDC_URL}" \
    --client-id-list sts.amazonaws.com
fi

cat > trust-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "${OIDC_PROVIDER_ARN}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:${REPO}:ref:${BRANCH_PATTERN}"
        }
      }
    }
  ]
}
EOF

if ! aws iam get-role --role-name "${ROLE_NAME}" >/dev/null 2>&1; then
  aws iam create-role \
    --role-name "${ROLE_NAME}" \
    --assume-role-policy-document file://trust-policy.json
else
  aws iam update-assume-role-policy \
    --role-name "${ROLE_NAME}" \
    --policy-document file://trust-policy.json
fi

aws iam attach-role-policy \
  --role-name "${ROLE_NAME}" \
  --policy-arn "${POLICY_ARN}"

aws iam get-role \
  --role-name "${ROLE_NAME}" \
  --query 'Role.Arn' \
  --output text
