data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

resource "aws_kms_key" "eks_secrets" {
  description             = "${var.env}-${var.project}-eks-secrets-kms"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

data "aws_iam_policy_document" "eks_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "eks_secrets_kms" {
  statement {
    sid    = "AllowKeyAdministration"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion",
    ]
    resources = [aws_kms_key.eks_secrets.arn]
  }

  statement {
    sid    = "AllowEKSClusterUseOfKey"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.eks.arn]
    }

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]
    resources = [aws_kms_key.eks_secrets.arn]
  }

  statement {
    sid    = "AllowEKSClusterGrantManagement"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.eks.arn]
    }

    actions = [
      "kms:CreateGrant",
    ]
    resources = [aws_kms_key.eks_secrets.arn]
  }
}

resource "aws_iam_role" "eks" {
  name = "${var.env}-${var.project}-eks-cluster"

  assume_role_policy = data.aws_iam_policy_document.eks_assume_role.json
}

resource "aws_iam_role_policy_attachment" "eks" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks.name
}

resource "aws_kms_key_policy" "eks_secrets" {
  key_id = aws_kms_key.eks_secrets.id
  policy = data.aws_iam_policy_document.eks_secrets_kms.json
}

resource "aws_kms_alias" "eks_secrets" {
  name          = "alias/${var.env}-${var.project}-eks-secrets"
  target_key_id = aws_kms_key.eks_secrets.key_id
}

#trivy:ignore:AVD-AWS-0040 trivy:ignore:AVD-AWS-0041
resource "aws_eks_cluster" "eks" {
  #checkov:skip=CKV_AWS_339:EKS 1.34 is supported by AWS; local Checkov rule set is outdated.
  #checkov:skip=CKV_AWS_39:Public endpoint is intentionally enabled and restricted to explicit operator CIDRs.
  #checkov:skip=CKV_AWS_38:Public endpoint is intentionally enabled and restricted to explicit operator CIDRs.
  name                      = "${var.env}-${var.project}-eks-cluster"
  version                   = var.eks_version
  role_arn                  = aws_iam_role.eks.arn
  enabled_cluster_log_types = var.eks_enabled_cluster_log_types

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = var.eks_public_access_cidrs

    subnet_ids = var.private_subnet_ids
  }

  encryption_config {
    provider {
      key_arn = aws_kms_key.eks_secrets.arn
    }

    resources = ["secrets"]
  }

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks,
    aws_kms_key_policy.eks_secrets,
    aws_kms_alias.eks_secrets,
  ]
}
