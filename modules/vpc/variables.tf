variable "env" {
  type = string
}

variable "region" {
  type = string
}

variable "project" {
  type = string
}

variable "component" {
  type = string
}

variable "vpc_cidr" {
  type    = string
  default = "10.1.0.0/16"
}

variable "cluster_tag_value" {
  type    = string
  default = "owned"
}

variable "az_count" {
  type    = number
  default = 2
}

variable "tags" {
  type    = map(string)
  default = {}
}
