#!/usr/bin/env bash
set -euo pipefail

# S3 Account Regional Namespace - bucket names are unique per account+region
# Bucket name format: <prefix>-<account_id>-<region>-an

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION=${AWS_REGION:-us-east-1}
TF_STATE_BUCKET="terraform-state-${AWS_ACCOUNT_ID}-${AWS_REGION}-an"

echo "Creating S3 state bucket: ${TF_STATE_BUCKET} (account-regional namespace)"

aws s3api create-bucket \
  --bucket "$TF_STATE_BUCKET" \
  --region "$AWS_REGION" \
  --bucket-namespace "account-regional"

aws s3api put-bucket-versioning \
  --bucket "$TF_STATE_BUCKET" \
  --versioning-configuration Status=Enabled

aws s3api put-bucket-encryption \
  --bucket "$TF_STATE_BUCKET" \
  --server-side-encryption-configuration '{
    "Rules": [
      {
        "ApplyServerSideEncryptionByDefault": {
          "SSEAlgorithm": "AES256"
        }
      }
    ]
  }'

aws s3api put-public-access-block \
  --bucket "$TF_STATE_BUCKET" \
  --public-access-block-configuration \
  BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

echo "✅ S3 state bucket created: ${TF_STATE_BUCKET}"
echo ""
echo "Use this in your backend config:"
echo "  bucket = \"${TF_STATE_BUCKET}\""
echo "  region = \"${AWS_REGION}\""
