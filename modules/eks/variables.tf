variable "project" { type = string }
variable "env" { type = string }

variable "eks_version" {
  type    = string
  default = "1.34"
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "eks_public_access_cidrs" {
  type = list(string)
}

variable "eks_enabled_cluster_log_types" {
  type = list(string)

  default = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler",
  ]
}
