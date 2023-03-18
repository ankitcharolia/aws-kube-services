
variable "cluster_identity_oidc_issuer_url" {
  type        = string
  description = "The OIDC Identity issuer for the cluster."
}

variable "cluster_identity_oidc_issuer_arn" {
  type        = string
  description = "The OIDC Identity issuer ARN for the cluster that can be used to associate IAM roles with a service account."
}

variable "service_account_name" {
  type        = string
  description = "Kubernetes Pod service account name"
}

variable "namespace" {
  type        = string
  description = "Helm Chart Namespace"
}

variable "role_name" {
  description = "IAM role name"
  type        = string
  default     = null
}

variable "role_policy_arns" {
  description = "ARN of IAM policies to attach to IAM role"
  type        = string
}