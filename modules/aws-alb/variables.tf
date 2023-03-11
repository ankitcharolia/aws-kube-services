variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnets" {
  description = "List of subnets"
  type        = list
  default     = []  
}

variable "bucket" {
  description = "Name of bucket"
  type = string
  default = null
}