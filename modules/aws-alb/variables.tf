variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnets" {
  description = "List of subnets"
  type        = list(any)
  default     = []
}

variable "bucket" {
  description = "Name of bucket"
  type        = string
  default     = null
}

variable "public_zone_name" {
  type        = string
  description = "This is the name of the hosted zone"
}
