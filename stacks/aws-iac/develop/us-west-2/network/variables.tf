data "aws_availability_zones" "available" {
  state = "available"
}
locals {
  cluster_name = "${var.project}-eks"
  azs          = slice(data.aws_availability_zones.available.names, 0, 2)
  az_map       = { for idx, az in local.azs : az => idx }

  common_tags = merge(var.tags, {
    Environment = var.env
    Project     = var.project
    Component   = var.component
    Region      = var.region
    Terraform   = "true"
  })
}

variable "env" { type = string }
variable "region" { type = string }
variable "project" { type = string }
variable "component" { type = string }

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
