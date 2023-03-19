output "security_group_id" {
  value = toset([
    for key, value in aws_security_group.this : {
      (key) : {
        "id" = value.id
      }
    }
  ])
}