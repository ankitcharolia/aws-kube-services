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
