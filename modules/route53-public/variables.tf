variable "public_zones" {
  description = "Map of Route53 zone parameters"
  type        = any
  default     = {}
}

variable "delegation_set_id" {
  description = "Map of Route53 delegation set parameters"
  type        = any
  default     = null
}

variable "public_zone_a_records" {
  type        = map(any)
  description = "A map with record name and IP address value."
  default     = {}
}

variable "public_zone_cname_records" {
  type        = map(any)
  description = "A map with record name and CNAME value."
  default     = {}
}

variable "public_zone_name" {
  type        = string
  description = "This is the name of the hosted zone"
}

variable "public_zone_comment" {
  type        = string
  description = "A comment for the hosted zone."
  default     = null
}

variable "force_destroy" {
  type        = bool
  description = "Whether to destroy all records in the zone when destroying the zone."
  default     = false
}

variable "public_zone_tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the zone."
  default = {}
}

variable "public_zone_nameservers" {
  type        = map(any)
  description = "A map with the subdomain name and a list of name servers that host the subzone configuration."
  default     = {}
}

variable "public_zone_aliases" {
  description = "List of Private Zone aliases"
  type = any
  default = []
}