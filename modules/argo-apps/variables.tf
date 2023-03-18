variable "repo_url" {
  description = "Helm chart repository URL"
  type        = string
}

variable "name" {
  description = "Name of the ArgoCD app deployment"
  type        = string
}

variable "namespace" {
  type        = string
  description = "Namespace to deploy helm chart into"
}

variable "prune" {
  type    = bool
  default = true
}

variable "self_heal" {
  type    = bool
  default = true
}

variable  "chart" {
  type        = string
  description = "The name of the Helm chart"
  default     = null
}

variable "target_revision" {
  type        = string
  description = "Helm chart version or git branch/tag for git hosted charts"
}

variable "path" {
  description = "The path to the chart within the Git repository. Path has no meaning for the external chart"
  type        = string
  default     = null
}

variable "values" {
  type        = any
  description = "Helm values"
  default     = {}
}

variable "value_files" {
  type        = list(string)
  description = "list of Helm value files for the chart"
  default     = []
}

variable "ignore_differences" {
  type    = list(any)
  default = []
}

variable "wait_for" {
  type    = map(string)
  default = {
    "status.health.status"  = "Healthy"
  }
}

variable "enable_multi_sources" {
  type    = bool
  default = true
}