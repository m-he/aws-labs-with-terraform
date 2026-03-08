data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  cluster_name   = "${var.project}-eks"
  azs            = slice(data.aws_availability_zones.available.names, 0, var.az_count)
  az_map         = { for idx, az in local.azs : az => idx }
  subnet_newbits = ceil(log(2 * var.az_count, 2))
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name = "${var.project}-vpc"
  })
}

resource "aws_subnet" "private" {
  for_each          = local.az_map
  vpc_id            = aws_vpc.main.id
  availability_zone = each.key
  cidr_block        = cidrsubnet(var.vpc_cidr, local.subnet_newbits, each.value)

  tags = merge(var.tags, {
    Name                                          = "${var.project}-private-${each.key}"
    "kubernetes.io/role/internal-elb"             = "1"
    "kubernetes.io/cluster/${local.cluster_name}" = var.cluster_tag_value
  })
}

resource "aws_subnet" "public" {
  for_each                = local.az_map
  vpc_id                  = aws_vpc.main.id
  availability_zone       = each.key
  cidr_block              = cidrsubnet(var.vpc_cidr, local.subnet_newbits, each.value + var.az_count)
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name                                          = "${var.project}-public-${each.key}"
    "kubernetes.io/role/elb"                      = "1"
    "kubernetes.io/cluster/${local.cluster_name}" = var.cluster_tag_value
  })
}
