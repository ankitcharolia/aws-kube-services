locals {
  secret_data_content = yamldecode(data.aws_kms_secrets.this.plaintext["secrets"])
}

# Decrypt multiple secrets from data encrypted with the AWS KMS service
data "aws_kms_secrets" "this" {
  secret {
    name = "secrets"
    payload = file("./etc/secrets/${var.environment}.yaml.encrypted")
  }
}

# create AWS secrets manager secret ID
resource "aws_secretsmanager_secret" "this" {
  for_each = { for secret in local.secret_data_content.secrets : secret.secret_id => secret }

  name = upper(replace(each.value.secret_id,"-","_"))
}

# store secret key data to AWS secrets manager secret ID
resource "aws_secretsmanager_secret_version" "this" {
  for_each = { for secret in local.secret_data_content.secrets : secret.secret_id => secret }

  secret_id     = aws_secretsmanager_secret.this[each.key].id
  secret_string = chomp(each.value.secret_data)
}