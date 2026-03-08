data "aws_caller_identity" "current" {}

resource "aws_kms_key" "cloudwatch_logs" {
  description         = "${var.project}-${var.env} CMK for CloudWatch Logs encryption"
  enable_key_rotation = true

  tags = merge(var.tags, {
    Name = "${var.project}-${var.env}-cloudwatch-logs-key"
  })
}

data "aws_iam_policy_document" "kms_cloudwatch_logs" {
  statement {
    sid    = "AllowKeyAdministration"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
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
    resources = [aws_kms_key.cloudwatch_logs.arn]
  }

  statement {
    sid    = "AllowCloudWatchLogsEncryption"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["logs.${var.region}.amazonaws.com"]
    }

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]
    resources = [aws_kms_key.cloudwatch_logs.arn]

    condition {
      test     = "ArnLike"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values   = ["arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:*"]
    }
  }
}

resource "aws_kms_key_policy" "cloudwatch_logs" {
  key_id = aws_kms_key.cloudwatch_logs.id
  policy = data.aws_iam_policy_document.kms_cloudwatch_logs.json
}

resource "aws_kms_alias" "cloudwatch_logs" {
  name          = "alias/${var.project}-${var.env}-cloudwatch-logs"
  target_key_id = aws_kms_key.cloudwatch_logs.key_id
}

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/aws/vpc/${var.project}-${var.env}-flow-logs"
  kms_key_id        = aws_kms_key.cloudwatch_logs.arn
  retention_in_days = var.vpc_flow_log_retention_in_days

  tags = merge(var.tags, {
    Name = "${var.project}-${var.env}-vpc-flow-logs"
  })
}

data "aws_iam_policy_document" "vpc_flow_logs_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "vpc_flow_logs_to_cloudwatch" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["${aws_cloudwatch_log_group.vpc_flow_logs.arn}:*"]
  }
}

resource "aws_iam_role" "vpc_flow_logs" {
  name               = "${var.project}-${var.env}-vpc-flow-logs-role"
  assume_role_policy = data.aws_iam_policy_document.vpc_flow_logs_assume_role.json

  tags = merge(var.tags, {
    Name = "${var.project}-${var.env}-vpc-flow-logs-role"
  })
}

resource "aws_iam_role_policy" "vpc_flow_logs" {
  name   = "${var.project}-${var.env}-vpc-flow-logs-policy"
  role   = aws_iam_role.vpc_flow_logs.id
  policy = data.aws_iam_policy_document.vpc_flow_logs_to_cloudwatch.json
}

resource "aws_flow_log" "vpc" {
  iam_role_arn         = aws_iam_role.vpc_flow_logs.arn
  log_destination      = aws_cloudwatch_log_group.vpc_flow_logs.arn
  log_destination_type = "cloud-watch-logs"
  traffic_type         = var.vpc_flow_log_traffic_type
  vpc_id               = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "${var.project}-${var.env}-vpc-flow-log"
  })
}
