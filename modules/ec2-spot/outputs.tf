output "instance" {
  value = toset([
    for key, value in aws_spot_instance_request.this : {
      (key) : {
        "public_ip"   = value.public_ip
        "private_ip"  = value.private_ip
        "id"          = value.spot_instance_id
        "arn"         = value.arn
        "private_dns" = value.private_dns
        "public_dns"  = value.public_dns
      }
    }
  ])
}
