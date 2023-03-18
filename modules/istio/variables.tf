variable "target_revision" {
  type        = string
  description = "Helm chart version or git branch/tag for git hosted charts"
}

variable "istio_ingress_loadbalancer_ip" {
  type  = string
  description = "IP address for Istio Ingress Gateway"
}