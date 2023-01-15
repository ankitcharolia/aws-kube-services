locals {
  policy_data = yamldecode(file("./etc/policies.yaml"))
  group_data = yamldecode(file("./etc/groups.yaml"))

}

# -------------------------------------------------------------------------------------------------
# 1. Account Settings
# -------------------------------------------------------------------------------------------------

# Create account alias (if not empty)
resource "aws_iam_account_alias" "default" {
  count = var.account_alias != "" ? 1 : 0

  account_alias = var.account_alias
}

# Setup account password policy
resource "aws_iam_account_password_policy" "default" {
  count = var.account_pass_policy.manage == true ? 1 : 0

  allow_users_to_change_password = var.account_pass_policy.allow_users_to_change_password
  hard_expiry                    = var.account_pass_policy.hard_expiry
  max_password_age               = var.account_pass_policy.max_password_age
  minimum_password_length        = var.account_pass_policy.minimum_password_length
  password_reuse_prevention      = var.account_pass_policy.password_reuse_prevention
  require_lowercase_characters   = var.account_pass_policy.require_lowercase_characters
  require_numbers                = var.account_pass_policy.require_numbers
  require_symbols                = var.account_pass_policy.require_symbols
  require_uppercase_characters   = var.account_pass_policy.require_uppercase_characters
}

# -------------------------------------------------------------------------------------------------
# 2. Policies
# -------------------------------------------------------------------------------------------------

# Create customer managed policies
resource "aws_iam_policy" "policies" {
  for_each = { for policy in local.policy_data.policies : policy.name => policy }

  name        = each.value.name
  path        = try(each.value.path, "/")
  description = try(each.value.description, "")
  policy      = file("./files/policies/${each.value.name}.json")

  tags = {
    PolicyDescription = "${each.value.description}"
  }

}

# -------------------------------------------------------------------------------------------------
# 3. Groups
# -------------------------------------------------------------------------------------------------

# Create groups
resource "aws_iam_group" "groups" {
  for_each = { for group in local.group_data.groups : group.name => group }

  name = each.value.name
  path = try(each.value.path, "/")
}

