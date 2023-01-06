variable "project" {
  type        = string
  description = "Project Name"
}

variable "environment" {
  type        = string
  description = "Environment Name"
}

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