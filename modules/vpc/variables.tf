variable "project" { type = string }
variable "env" { type = string }
variable "region" { type = string }

variable "vpc_cidr" {
  type    = string
  default = "10.1.0.0/16"
}

variable "az_count" {
  type    = number
  default = 2
}

variable "cluster_tag_value" {
  type    = string
  default = "owned"
}

variable "vpc_flow_log_retention_in_days" {
  type    = number
  default = 365

  validation {
    condition     = var.vpc_flow_log_retention_in_days >= 365
    error_message = "vpc_flow_log_retention_in_days must be at least 365 days."
  }
}

variable "vpc_flow_log_traffic_type" {
  type    = string
  default = "ALL"
}

variable "tags" {
  type    = map(string)
  default = {}
}
