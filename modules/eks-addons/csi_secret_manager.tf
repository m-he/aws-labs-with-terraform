data "aws_iam_policy_document" "secretmanager_csi_driver" {
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

resource "aws_iam_role" "secretmanager_csi_driver" {
  name               = "${var.eks_cluster_name}-secretmanager_csi_driver"
  assume_role_policy = data.aws_iam_policy_document.secretmanager_csi_driver.json
}

resource "aws_iam_role_policy_attachment" "secretmanager_csi_driver" {
  policy_arn = "arn:aws:iam::aws:policy/AWSSecretsManagerClientReadOnlyAccess"
  role       = aws_iam_role.secretmanager_csi_driver.name
}


resource "aws_eks_addon" "secretmanager_csi_driver" {
  cluster_name  = var.eks_cluster_name
  addon_name    = "aws-secrets-store-csi-driver-provider"
  addon_version = "v2.2.2-eksbuild.1"
  depends_on    = [data.aws_eks_node_group.this]
}


/* usage example of the above IAM role and addon for a default namespace service account, which can be used by workloads in the default namespace to read secrets from AWS Secrets Manager. You can create similar associations for other namespaces and service accounts as needed.
resource "kubernetes_service_account" "default_secretmanager_reader" {
  metadata {
    name      = "aws-secretmanager-reader"
    namespace = "default"
  }
  depends_on = [ aws_eks_cluster.eks ]
}

resource "aws_eks_pod_identity_association" "default_secretmanager" {
  role_arn = aws_iam_role.secretmanager_csi_driver.arn
  service_account = kubernetes_service_account.default_secretmanager_reader.metadata[0].name
  namespace = "default"
  cluster_name = aws_eks_cluster.eks.name
}

*/
