variable "region" {
  type = string
}

variable "target_revision" {
  type        = string
  description = "Helm chart version or git branch/tag for git hosted charts"
}

variable "cluster_identity_oidc_issuer_url" {
  type        = string
  description = "The OIDC Identity issuer for the cluster."
}

variable "cluster_identity_oidc_issuer_arn" {
  type        = string
  description = "The OIDC Identity issuer ARN for the cluster that can be used to associate IAM roles with a service account."
}
