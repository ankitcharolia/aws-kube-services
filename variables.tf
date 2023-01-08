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

variable "public_zones" {
  description = "Map of Route53 public zone parameters"
  type        = any
  default     = {}
}

variable "private_zones" {
  description = "Map of Route53 private zone parameters"
  type        = any
  default     = {}
}

variable "delegation_set_id" {
  description = "Map of Route53 delegation set parameters"
  type        = any
  default     = {}
}
