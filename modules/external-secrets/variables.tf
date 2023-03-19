variable "name" {
  type        = string
  description = "Deployment Name"
}

variable "namespace" {
  type        = string
  description = "Helm Chart Namespace"
}

variable "chart_repository" {
  type        = string
  description = "Helm Chart Repository"
}

variable "chart_name" {
  type        = string
  description = "Helm Chart Name"
}

variable "chart_version" {
  type        = string
  description = "Helm Chart Version"
}

variable "service_account_name" {
  type        = string
  default     = "external-secrets"
  description = "External Secrets service account name"
}

variable "region" {
  type = string
}

variable "cluster_identity_oidc_issuer_url" {
  type        = string
  description = "The OIDC Identity issuer for the cluster."
}

variable "cluster_identity_oidc_issuer_arn" {
  type        = string
  description = "The OIDC Identity issuer ARN for the cluster that can be used to associate IAM roles with a service account."
}
