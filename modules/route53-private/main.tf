# -------------------------------------------------------------------------------------------------
#  Route53 Zone
# -------------------------------------------------------------------------------------------------
resource "aws_route53_zone" "private" {

  name    = var.private_zone_name
  comment = var.private_zone_comment
  dynamic "vpc" {
    for_each = var.vpc_id
    iterator = vpcid
    content {
      vpc_id = vpcid.value
    }
  }
  force_destroy = var.force_destroy

  tags = merge(var.private_zone_tags, {
    # managedBy   = "Terraform"
  })

}

# -------------------------------------------------------------------------------------------------
#  Zone RecordSet
# -------------------------------------------------------------------------------------------------

resource "aws_route53_record" "a_record" {
  for_each = try(var.private_zone_a_records, tomap({}))
  zone_id  = aws_route53_zone.private.zone_id
  name     = "${each.key}.${aws_route53_zone.private.name}"
  type     = "A"
  ttl      = "300"
  records  = each.value
}

resource "aws_route53_record" "cname_record" {
  for_each = try(var.private_zone_cname_records, tomap({}))
  zone_id  = aws_route53_zone.private.zone_id
  name     = each.key
  type     = "CNAME"
  ttl      = "300"
  records  = each.value
}

resource "aws_route53_record" "nameserver" {
  for_each        = try(var.private_zone_nameservers, tomap({}))
  zone_id         = aws_route53_zone.private.zone_id
  allow_overwrite = false
  name            = each.key
  type            = "NS"
  ttl             = "300"
  records         = each.value
}

resource "aws_route53_record" "private_alias" {
  for_each = { for alias in var.private_zone_aliases : alias.name => alias }

  zone_id         = aws_route53_zone.private.zone_id
  name            = each.value.name
  allow_overwrite = try(each.value.allow_overwrite, false)
  type            = each.value.type

  alias {
    name                   = each.value.alias_name
    zone_id                = try(each.value.alias_zone_id, aws_route53_zone.private.zone_id)
    evaluate_target_health = false
  }
}


