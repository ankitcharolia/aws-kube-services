variable "private_zones" {
  description = "Map of Route53 zone parameters"
  type        = any
  default     = {}
}

variable "region" {
  description = "Region of the VPC"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = set(string)
}