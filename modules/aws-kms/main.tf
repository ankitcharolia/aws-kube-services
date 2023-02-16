locals {
  key_id = var.use_aws_key_material ? aws_kms_key.this[0].key_id : aws_kms_external_key.this[0].id
  arn    = var.use_aws_key_material ? aws_kms_key.this[0].arn : aws_kms_external_key.this[0].arn
}

# get information about the AWS account
data "aws_caller_identity" "current" {}

# Creates/manages KMS CMK
resource "aws_kms_key" "this" {
  count                     = var.use_aws_key_material ? 1 : 0
  description               = var.description
  customer_master_key_spec  = var.key_spec
  is_enabled                = var.enabled
  enable_key_rotation       = var.rotation_enabled
  key_usage                 = var.key_usage
  tags                      = {
    Name        = var.kms_alias
  }
  policy                    = try(templatefile("./files/policies/aws-kms-${trimprefix(var.kms_alias, "alias/")}-policy.json", {
      aws_account_id = data.aws_caller_identity.current.account_id
  }), null)

  deletion_window_in_days   = var.deletion_window_in_days
}

resource "aws_kms_external_key" "this" {
  count                     = var.use_aws_key_material ? 0 : 1

  description               = var.description
  enabled                   = var.enabled
  # WARNING: key material will be stored in the raw state as plaintext.
  key_material_base64       = var.key_material_base64
  policy                    = try(templatefile("./files/policies/aws-kms-${trimprefix(var.kms_alias, "alias/")}-policy.json", {
      aws_account_id = data.aws_caller_identity.current.account_id
  }), null)  
  tags                      =  {
    Name        = var.kms_alias
  }
  valid_to                  = var.valid_to
  deletion_window_in_days   = var.deletion_window_in_days
}

# Add an alias to the key
resource "aws_kms_alias" "this" {
  name          = var.kms_alias
  target_key_id = local.key_id
}