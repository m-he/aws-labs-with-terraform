data "aws_availability_zones" "available" {
  state = "available"
}
locals {
  region       = "us-west-2"
  cluster_name = "${var.env}-${var.eks_name}"
  azs          = slice(data.aws_availability_zones.available.names, 0, 2)
  az_map       = { for idx, az in local.azs : az => idx }

  common_tags = merge(var.tags, {
    Environment = var.env
    Terraform   = "true"
  })
}

variable "env" { type = string }
variable "eks_name" { type = string }

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "cluster_tag_value" {
  type    = string
  default = "owned"
}

variable "tags" {
  type    = map(string)
  default = {}
}
