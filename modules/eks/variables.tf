variable "project" {
  description = "Name to be used on all the resources as identifier. e.g. Project name, Application name"
  type = string
}

variable "eks_node_groups" {
  type        = any
  description = "List of EKS Node Groups"
  default     = []
}

variable "capacity_type" {
  type = string
  description = "Type of the EKS node group: ON_DEMAND or SPOT"
  default = "ON_DEMAND"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnets"
  type        = list
  default     = []  
}

variable "kubernetes_version" {
  type        = string
  description = "Version of EKS"
}

variable "aws_eks_addons" {
  type        = set(string)
  default     = []
}

variable "oidc_provider_enabled" {
  type        = bool
  description = "whether to enable OIDC provider or not"
  default     = true
}
