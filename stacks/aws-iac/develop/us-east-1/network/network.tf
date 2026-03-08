module "network" {
  source                         = "../../../../../modules/vpc"
  project                        = var.project
  env                            = var.env
  region                         = var.region
  vpc_cidr                       = var.vpc_cidr
  cluster_tag_value              = var.cluster_tag_value
  tags                           = local.common_tags
  vpc_flow_log_retention_in_days = var.vpc_flow_log_retention_in_days
  vpc_flow_log_traffic_type      = var.vpc_flow_log_traffic_type
}


module "eks" {
  source                  = "../../../../../modules/eks"
  project                 = var.project
  env                     = var.env
  eks_version             = var.eks_version
  private_subnet_ids      = module.network.private_subnet_ids
  eks_public_access_cidrs = ["70.190.232.143/32"]
}
