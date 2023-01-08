# zone outputs

output "route53_public_zone_id" {
  description = "Zone ID of Route53 zone"
  value       = { for k, v in aws_route53_zone.public : k => v.zone_id }
}

output "route53_public_zone_arn" {
  description = "Zone ARN of Route53 zone"
  value       = { for k, v in aws_route53_zone.public : k => v.arn }
}

output "route53_public_name_servers" {
  description = "Name servers of Route53 zone"
  value       = { for k, v in aws_route53_zone.public : k => v.name_servers }
}

output "route53_public_zone_name" {
  description = "Name of Route53 zone"
  value       = { for k, v in aws_route53_zone.public : k => v.name }
}

