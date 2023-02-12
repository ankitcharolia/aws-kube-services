# -------------------------------------------------------------------------------------------------
# Account setting transformations
# -------------------------------------------------------------------------------------------------

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
