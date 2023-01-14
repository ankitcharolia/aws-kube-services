# -------------------------------------------------------------------------------------------------
#  Route53 Zone
# -------------------------------------------------------------------------------------------------
resource "aws_route53_zone" "public" {

    name              = var.public_zone_name
    comment           = var.public_zone_comment
    delegation_set_id = var.delegation_set_id
    force_destroy     = var.force_destroy

    tags  = merge(var.public_zone_tags, {
      managedBy   = "Terraform"
    })

}

# -------------------------------------------------------------------------------------------------
#  Zone RecordSet
# -------------------------------------------------------------------------------------------------

resource "aws_route53_record" "a_record" {
  for_each  = try(var.public_zone_a_records, tomap({}))
  zone_id   = aws_route53_zone.public.zone_id
  name      = "${each.key}.${aws_route53_zone.public.name}"
  type      = "A"
  ttl       = "300"
  records   = [each.value]
}

resource "aws_route53_record" "cname_record" {
  for_each  = try(var.public_zone_cname_records, tomap({}))
  zone_id   = aws_route53_zone.public.zone_id
  name      = each.key
  type      = "CNAME"
  ttl       = "300"
  records   = [each.value]
}

resource "aws_route53_record" "nameserver" {
  for_each        = try(var.public_zone_nameservers, tomap({}))
  zone_id         = aws_route53_zone.public.zone_id
  allow_overwrite = true
  name            = each.key
  type            = "NS"
  ttl             = "300"
  records         = each.value
}
