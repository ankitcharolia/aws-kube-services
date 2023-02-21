variable "project" {
  type        = string
  description = "Project Name"
}

variable "environment" {
  type        = string
  description = "Environment Name"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC"
}

variable "port" {
  type        = number
  description = "Port of RDS instance to connect"
}

variable "cidr_blocks" {
  type        = any
  description = "List of cidr blocks for the security group"
  default     = []
}

##############################################################################################################################################################
# DB Subnet Group Variables
##############################################################################################################################################################
variable "subnet_ids" {
  description = "A list of VPC subnet IDs"
  type        = list(string)
  default     = []
}

variable "create_db_subnet_group" {
  type        = bool
  default     = true
}

################################################################################################################################################################
# DB Options and Parameter Group Variables
################################################################################################################################################################
variable "create_db_option_group" {
  description = "Whether to create DB option group"
  type        = bool
  default     = false
}

variable "create_db_parameter_group" {
  description = "Whether to create DB parameter group"
  type        = bool
  default     = false
}

variable "name" {
  description = "The name of the Database"
  type        = string
  default     = ""
}

variable "family" {
  description = "The family of the DB parameter group"
  type        = string
  default     = null
}

variable "parameters" {
  description = "A list of DB parameter maps to apply"
  type        = list(map(string))
  default     = []
}

variable "engine_name" {
  description = "Specifies the name of the engine that this option group should be associated with"
  type        = string
  default     = null
}

variable "major_engine_version" {
  description = "Specifies the major version of the engine that this option group should be associated with"
  type        = string
  default     = null
}

variable "options" {
  description = "A list of Options to apply"
  type        = any
  default     = []
}

variable "db_option_group_timeouts" {
  description   = "Define maximum timeout for deletion of `aws_db_option_group` resource"
  type          = string
  default       = "15m"
}

################################################################################################################################################################
# DB Instance Variables
################################################################################################################################################################
