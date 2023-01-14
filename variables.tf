# common variables
variable "project" {
  type        = string
  description = "Project Name"
}

variable "environment" {
  type        = string
  description = "Environment Name"
}

variable "region" {
  type        = string
  description = "AWS Region Name"
}

# VPC Variables
variable "enable_public_subnet" {
  type        = bool
  description = "Enable public subnets if needed"
}

variable "availability_zones_count" {
  description = "The number of AZs."
  type        = number
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "subnet_cidr_bits" {
  description = "The number of subnet bits for the CIDR"
  type        = number
}

# Route53 variables
## Public DNS Zone Variables

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
}

## Private DNS Zone Variables

variable "private_zone_a_records" {
  type        = map(any)
  description = "A map with record name and IP address value."
  default     = {}
}

variable "private_zone_cname_records" {
  type        = map(any)
  description = "A map with record name and CNAME value."
  default     = {}
}

variable "private_zone_name" {
  type        = string
  description = "This is the name of the hosted zone"
}

variable "private_zone_comment" {
  type        = string
  description = "A comment for the hosted zone."
  default     = null
}

variable "private_zone_tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the zone."
  default = {}
}

variable "private_zone_nameservers" {
  type        = map(any)
  description = "A map with the subdomain name and a list of name servers that host the subzone configuration."
  default     = {}
}

variable "private_zone_aliases" {
  description = "List of Private Zone aliases"
  type = any
}
