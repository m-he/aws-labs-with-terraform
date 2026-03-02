resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, {
    Name = "${local.cluster_name}-vpc"
  })
}

resource "aws_subnet" "private" {
  for_each          = local.az_map
  vpc_id            = aws_vpc.main.id
  availability_zone = each.key
  cidr_block        = cidrsubnet(var.vpc_cidr, 2, each.value)

  tags = merge(local.common_tags, {
    Name                                          = "${local.cluster_name}-private-${each.key}"
    "kubernetes.io/role/internal-elb"             = "1"
    "kubernetes.io/cluster/${local.cluster_name}" = var.cluster_tag_value
  })
}

resource "aws_subnet" "public" {
  for_each                = local.az_map
  vpc_id                  = aws_vpc.main.id
  availability_zone       = each.key
  cidr_block              = cidrsubnet(var.vpc_cidr, 2, each.value + 2)
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name                                          = "${local.cluster_name}-public-${each.key}"
    "kubernetes.io/role/elb"                      = "1"
    "kubernetes.io/cluster/${local.cluster_name}" = var.cluster_tag_value
  })
}
