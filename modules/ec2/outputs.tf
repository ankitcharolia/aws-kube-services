output "instance" {
  value = toset([
    for key, value in aws_instance.this : {
      (key) : {
        "public_ip"   = value.public_ip
        "private_ip"  = value.private_ip
        "id"          = value.id
        "arn"         = value.arn
        "private_dns" = value.private_dns
        "public_dns"  = value.public_dns
      }
    }
  ])
}
