locals {
  policy_data = yamldecode(file("./etc/policies.yaml"))
  group_data = yamldecode(file("./etc/groups.yaml"))
  user_data = yamldecode(file("./etc/users.yaml"))

  group_policies  = flatten([for group in local.group_data.groups : [
      for policy in try(group.policies, []) : {
        name      = group.name
        policy    = policy
      }
    ]
  ])

  group_policy_arns = flatten([for group in local.group_data.groups : [
      for policy_arn in try(group.policy_arns, []) : {
        name        = group.name
        policy_arn  = policy_arn
      }
    ]
  ])

  user_groups = flatten([for user in local.user_data.users : [
      for group in try(user.groups, []) : {
        name      = user.name
        groups    = group
      }
    ]
  ])

  user_policies  = flatten([for user in local.user_data.users : [
      for policy in try(user.policies, []) : {
        name      = user.name
        policy    = policy
      }
    ]
  ])

  user_policy_arns = flatten([for user in local.user_data.users : [
      for policy_arn in try(user.policy_arns, []) : {
        name        = user.name
        policy_arn  = policy_arn
      }
    ]
  ])

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
  description = each.value.description
  policy      = templatefile("./files/policies/${each.value.name}.json", {
      aws_account_id = var.aws_account_id
  })

  tags = {
    PolicyDescription = each.value.description
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

# # Attach customer managed policies to group
resource "aws_iam_group_policy_attachment" "policy_attachments" {
  for_each =  { for idx, record in local.group_policies : idx => record }

  group      = each.value.name
  policy_arn = aws_iam_policy.policies[each.value.policy].arn

  depends_on = [
    aws_iam_group.groups,
    aws_iam_policy.policies,
  ]
}

# Attach policy ARNs to group
resource "aws_iam_group_policy_attachment" "policy_arn_attachments" {
  for_each =  { for idx, record in local.group_policy_arns : idx => record }

  group      = each.value.name
  policy_arn = each.value.policy_arn

  depends_on = [aws_iam_group.groups]
}

# -------------------------------------------------------------------------------------------------
# 4. Users
# -------------------------------------------------------------------------------------------------

# Create users
resource "aws_iam_user" "users" {
  for_each = { for user in local.user_data.users : user.name => user }

  name = each.value.name
  path = try(each.value.path, "/") 

  # The boundary defines the maximum allowed permissions which cannot exceed.
  # Even if the policy has higher permission, the boundary sets the final limit
  permissions_boundary = try(each.value.permissions_boundary, null)

  tags = {
    Name = each.value.name
  }
}

# Attach customer managed policies to user
resource "aws_iam_user_policy_attachment" "policy_attachments" {
  for_each =  { for idx, record in local.user_policies : idx => record }

  user       = each.value.name
  policy_arn = aws_iam_policy.policies[each.value.policy].arn

  depends_on = [
    aws_iam_user.users,
    aws_iam_policy.policies,
  ]
}

# Attach policy ARNs to user
resource "aws_iam_user_policy_attachment" "policy_arn_attachments" {
  for_each =  { for idx, record in local.user_policy_arns : idx => record }

  user       = each.value.name
  policy_arn = each.value.policy_arn

  depends_on = [aws_iam_user.users]
}

# Add users to groups
resource "aws_iam_user_group_membership" "group_membership" {
  for_each =  { for idx, record in local.user_groups : idx => record }

  user   = each.value.name
  groups = [
    each.value.groups,
  ]
  depends_on = [
    aws_iam_user.users,
    aws_iam_group.groups,
  ]
}

# Uploads an SSH public key and associates it with the specified IAM user.
resource "aws_iam_user_ssh_key" "user" {
  for_each = { for user in local.user_data.users : user.name => user if can(user.ssh_key) }

  username   = each.value.name
  encoding   = "SSH"
  public_key = try(each.value.ssh_key, "")
}

# Add 'Active' or 'Inactive' access key to an IAM user
# resource "aws_iam_access_key" "access_key" {
#   for_each = local.user_access_keys

#   user    = split(":", each.key)[0]
#   pgp_key = each.value.pgp_key
#   status  = each.value.status

#   Terraform has no info that aws_iam_users must be run first in order to create the users,
#   so we must explicitly tell it.
#   depends_on = [aws_iam_user.users]
# }