data "aws_iam_policy_document" "network_flow_monitoring_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }
}

resource "aws_iam_role" "network_flow_monitoring" {
  name               = "${var.eks_cluster_name}-network_flow_monitoring"
  assume_role_policy = data.aws_iam_policy_document.network_flow_monitoring_policy.json
}

resource "aws_iam_role_policy_attachment" "network_flow_monitoring" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchNetworkFlowMonitorAgentPublishPolicy"
  role       = aws_iam_role.network_flow_monitoring.name
}


resource "aws_eks_addon" "network_flow_monitoring" {
  cluster_name  = var.eks_cluster_name
  addon_name    = "aws-network-flow-monitoring-agent"
  addon_version = "v1.1.3-eksbuild.2"

  pod_identity_association {
    role_arn        = aws_iam_role.network_flow_monitoring.arn
    service_account = "aws-network-flow-monitor-agent-service-account"
  }
  depends_on = [data.aws_eks_node_group.this]
}
