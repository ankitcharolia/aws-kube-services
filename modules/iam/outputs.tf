output "credentials" {
  value = toset([
    for key, value in aws_iam_user_login_profile.user_profile : {
      (value.user) :  value.encrypted_password
    }
  ])
}