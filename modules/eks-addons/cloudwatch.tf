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

# resource "aws_eks_addon" "cloudwatch" {
#   cluster_name  = var.eks_cluster_name
#   addon_name    = "amazon-cloudwatch-observability"
#   addon_version = "v5.2.1-eksbuild.1"
#   pod_identity_association {
#     role_arn        = aws_iam_role.cloudwatch_observability.arn
#     service_account = "cloudwatch-agent"
#   }
#   configuration_values = jsonencode(jsondecode(file("${path.module}/values/addon_cloudwatch_config.json")))
# }

resource "aws_eks_pod_identity_association" "aws_eks_cloudwatch_observability" {
  cluster_name    = var.eks_cluster_name
  namespace       = "amazon-cloudwatch"
  service_account = "cloudwatch-agent"
  role_arn        = aws_iam_role.cloudwatch_observability.arn
}

resource "helm_release" "aws_eks_cloudwatch_observability" {
  name = "amazon-cloudwatch-observability"

  repository = "https://aws-observability.github.io/helm-charts"
  chart      = "amazon-cloudwatch-observability"
  namespace  = "amazon-cloudwatch"
  version    = "4.10.0"

  create_namespace = true
  wait             = true
  timeout          = 600
  atomic           = true

  set = [{
    name  = "clusterName"
    value = var.eks_cluster_name
    },
    {
      name  = "region"
      value = var.region
  }]

  depends_on = [
    data.aws_eks_node_group.this,
    aws_eks_pod_identity_association.aws_eks_cloudwatch_observability,
    helm_release.aws_lbc,
  ]
}
