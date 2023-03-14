# ----------------------------------------------------------------
# common variables 
# ----------------------------------------------------------------
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

# ----------------------------------------------------------------
# VPC Variables
# ----------------------------------------------------------------
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

# ----------------------------------------------------------------
# Route53 variables
# ----------------------------------------------------------------
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

# ----------------------------------------------------------------
# IAM Variables
# ----------------------------------------------------------------

variable "account_alias" {
  description = "Assign the account alias for the AWS Account. Unmanaged by default. Resource will be created if the string is non-empty."
  type        = string
  default     = ""
}

variable "account_pass_policy" {
  description = "Manages Password Policy for the AWS Account. Unmanaged by default. Resource will be created if 'manage' is set to true."
  type = object({
    manage                         = bool   # Set to true, to manage the AWS account password policy
    allow_users_to_change_password = bool   # Allow users to change their own password?
    hard_expiry                    = bool   # Users are prevented from setting a new password after their password has expired?
    max_password_age               = number # Number of days that an user password is valid
    minimum_password_length        = number # Minimum length to require for user passwords
    password_reuse_prevention      = number # The number of previous passwords that users are prevented from reusing
    require_lowercase_characters   = bool   # Require lowercase characters for user passwords?
    require_numbers                = bool   # Require numbers for user passwords?
    require_symbols                = bool   # Require symbols for user passwords?
    require_uppercase_characters   = bool   # Require uppercase characters for user passwords?
  })
  default = {
    manage                         = false
    allow_users_to_change_password = null
    hard_expiry                    = null
    max_password_age               = null
    minimum_password_length        = null
    password_reuse_prevention      = null
    require_lowercase_characters   = null
    require_numbers                = null
    require_symbols                = null
    require_uppercase_characters   = null
  }
}

# ----------------------------------------------------------------
# AWS KMS Variables
# ----------------------------------------------------------------
variable "kms_alias" {
  type          = string
  description   = "The display name of the key."
  default = ""
  validation {
    condition     = var.kms_alias == "" || can(regex("alias\\/.+", var.kms_alias))
    error_message = "The name must start with the word 'alias' followed by a forward slash."
  }
}

variable "use_aws_key_material" {
  type          = bool
  description   = "Whether to use AWS managed key materia or customer managed key material"
  default       = false
}

# ----------------------------------------------------------------
# AWS RDS Variables
# ----------------------------------------------------------------
variable "rds_instances" {
  type        = any
  description = "List of AWS RDS Instances"
  default     = []
}

variable "bucket" {
  description = "Name of bucket"
  type        = string
  default     = null
}

# ----------------------------------------------------------------
# AWS EKS Variables
# ----------------------------------------------------------------
variable "kubernetes_version" {
  type        = string
  description = "Version of EKS"
}

variable "eks_node_groups" {
  type        = any
  description = "List of EKS Node Groups"
  default     = []
}

variable "aws_eks_addons" {
  type = set(string)
}
