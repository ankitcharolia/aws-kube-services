variable "public_zones" {
  description = "Map of Route53 zone parameters"
  type        = any
  default     = {}
}

variable "delegation_set_id" {
  description = "Map of Route53 delegation set parameters"
  type        = any
  default     = {}
}