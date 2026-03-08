resource "aws_eks_addon" "pod_identity" {
  cluster_name  = var.eks_cluster_name
  addon_name    = "eks-pod-identity-agent"
  addon_version = "v1.3.10-eksbuild.2"
}

data "aws_eks_node_group" "this" {
  cluster_name    = var.eks_cluster_name
  node_group_name = var.eks_node_group_name
}

resource "helm_release" "metrics_server" {
  name = "metrics-server"

  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"
  version    = "3.13.0"

  values = [file("${path.module}/values/metrics-server.yaml")]

  depends_on = [data.aws_eks_node_group.this]
}
