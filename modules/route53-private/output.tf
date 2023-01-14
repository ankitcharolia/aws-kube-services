# zone outputs

output "route53_private_zone_id" {
  description = "The Hosted Zone ID. This can be referenced by zone records."
  value       = aws_route53_zone.private.zone_id
}

output "route53_private_name_servers" {
  description = "A list of name servers in associated (or default) delegation set."
  value       = aws_route53_zone.private.name_servers
}

output "route53_private_zone_name" {
  description = "Name of Route53 zone"
  value       = aws_route53_zone.private.name
}

