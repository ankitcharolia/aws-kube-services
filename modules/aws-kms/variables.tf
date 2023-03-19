variable "description" {
  type        = string
  description = "The description of the key as viewed in AWS console."
  default     = "null"
}

variable "key_spec" {
  type        = string
  default     = "SYMMETRIC_DEFAULT"
  description = "Specifies whether the key contains a symmetric key or an asymmetric key pair and the encryption algorithms or signing algorithms that the key supports. Valid values: SYMMETRIC_DEFAULT, RSA_2048, RSA_3072, RSA_4096, ECC_NIST_P256, ECC_NIST_P384, ECC_NIST_P521, or ECC_SECG_P256K1"
}

variable "enabled" {
  type        = bool
  default     = true
  description = "Specifies whether the key is enabled."
}

variable "rotation_enabled" {
  type        = bool
  default     = false
  description = "Specifies whether key rotation is enabled."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A map of tags to assign to the key."
}

variable "kms_alias" {
  type        = string
  description = "The display name of the key."
  default     = ""
  validation {
    condition     = var.kms_alias == "" || can(regex("alias\\/.+", var.kms_alias))
    error_message = "The name must start with the word 'alias' followed by a forward slash."
  }
}

variable "policy" {
  type        = string
  description = "A valid policy JSON document. This is a key policy, not an IAM policy."
  default     = null
}

variable "deletion_window_in_days" {
  type        = number
  description = "Key will be deleted in days"
  default     = 30

  validation {
    condition     = var.deletion_window_in_days >= 7 && var.deletion_window_in_days <= 30
    error_message = "Must be between 7 and 30."
  }
}

variable "use_aws_key_material" {
  type        = bool
  description = "Whether to use AWS managed key materia or customer managed key material"
  default     = false
}

variable "key_material_base64" {
  description = "WARNING: if specified, it will be stored in plaintext in the raw state. Base64 encoded 256-bit symmetric encryption key material to import"
  type        = string
  default     = null
}

variable "valid_to" {
  description = "Time at which the imported key material expires. If not specified, key material does not expire. Valid values: RFC3339 time string (YYYY-MM-DDTHH:MM:SSZ)"
  type        = string
  default     = null
}

variable "key_usage" {
  description = "Specifies the intended use of the key"
  type        = string
  default     = null
}