output "key_id" {
  value       = local.key_id
  description = "The globally unique identifier for the KMS key."
}

output "key_arn" {
  value       = local.arn
  description = "The Amazon Resource Name (ARN) of the KMS key."
}

output "alias_arn" {
  value = join("", aws_kms_alias.this.*.arn)
}