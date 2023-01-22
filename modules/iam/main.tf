locals {
  policy_data = yamldecode(file("./etc/policies.yaml"))
  group_data = yamldecode(file("./etc/groups.yaml"))
  user_data = yamldecode(file("./etc/users.yaml"))
  role_data = yamldecode(file("./etc/roles.yaml"))

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

  user_login_profile = flatten([for user in local.user_data.users : [
      for access_key in try(user.access_keys, []) : {
        name      = user.name
        pgp_key   = access_key.pgp_key
      }
    ]
  ])

  role_policies  = flatten([for role in local.role_data.roles : [
      for policy in try(role.policies, []) : {
        name      = role.name
        policy    = policy
      }
    ]
  ])

  role_policy_arns = flatten([for role in local.role_data.roles : [
      for policy_arn in try(role.policy_arns, []) : {
        name        = role.name
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

# Add IAM user login profile
resource "aws_iam_user_login_profile" "user_profile" {
  for_each = { for user in local.user_data.users : user.name => user }

  user                    = each.value.name
  pgp_key                 = try(each.value.pgp_key, "")
  password_reset_required = true

  depends_on = [aws_iam_user.users]
}

# -------------------------------------------------------------------------------------------------
# 5. Roles
# -------------------------------------------------------------------------------------------------

# # Create roles
# resource "aws_iam_role" "roles" {
#   for_each = { for role in local.role_data.roles : role.name => role }

#   name        = each.value.name
#   path        = try(each.value.path, "/")
#   description = try(each.value.description, null)

#   # This policy defines who/what is allowed to use the current role
#   assume_role_policy  = templatefile(each.value.trust_policy_file, {
#     aws_account_id    = var.aws_account_id
#   })

#   # The boundary defines the maximum allowed permissions which cannot exceed.
#   # Even if the policy has higher permission, the boundary sets the final limit
#   permissions_boundary = try(each.value.permissions_boundary, null)

#   # Allow session for X seconds
#   max_session_duration  = try(each.value.role_max_session_duration, "3600")
#   force_detach_policies = try(each.value.role_force_detach_policies, true)

#   tags = {
#     Name = each.value.name
#   }
# }

# # Attach customer managed policies to roles
# resource "aws_iam_role_policy_attachment" "policy_attachments" {
#   for_each =  { for idx, record in local.role_policies : idx => record }

#   role       = each.value.name
#   policy_arn = aws_iam_policy.policies[each.value.policy].arn

#   depends_on = [
#     aws_iam_role.roles,
#     aws_iam_policy.policies,
#   ]
# }

# # Attach policy ARNs to roles
# resource "aws_iam_role_policy_attachment" "policy_arn_attachments" {
#   for_each =  { for idx, record in local.role_policy_arns : idx => record }

#   role       = each.value.name
#   policy_arn = each.value.policy_arn

#   depends_on = [aws_iam_role.roles]
# }
