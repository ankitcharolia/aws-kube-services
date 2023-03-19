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
  default     = null
}

variable "chart_name" {
  type        = string
  description = "Helm Chart Name"
}

variable "chart_version" {
  type        = string
  description = "Helm Chart Version"
  default     = null
}

variable "github_repo_url" {
  type = string
}

variable "public_zone_name" {
  type = string
}
