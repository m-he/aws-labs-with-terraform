resource "aws_iam_role" "cloudwatch_observability" {
  name = "${var.eks_cluster_name}-cloudwatch_observability"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "CloudWatchAgentServerPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.cloudwatch_observability.name
}

resource "aws_eks_addon" "cloudwatch" {
  cluster_name  = var.eks_cluster_name
  addon_name    = "amazon-cloudwatch-observability"
  addon_version = "v5.2.1-eksbuild.1"
  pod_identity_association {
    role_arn        = aws_iam_role.cloudwatch_observability.arn
    service_account = "cloudwatch-agent"
  }
  configuration_values = <<CONFIG
  {
    "agent": {
        "config": {
            "logs": {
                "metrics_collected": {
                    "kubernetes": {
                        "kueue_container_insights": true,
                        "enhanced_container_insights": true
                    },
                    "application_signals": { }
                }
            },
            "traces": {
                "traces_collected": {
                    "application_signals": { }
                }
            }
        },
    },
}
CONFIG
}
