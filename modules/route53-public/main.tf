# -------------------------------------------------------------------------------------------------
#  Route53 Zone
# -------------------------------------------------------------------------------------------------
resource "aws_route53_zone" "public" {
  for_each = try(var.public_zones, tomap({}))

  name          = each.key
  comment       = lookup(each.value, "comment", null)
  force_destroy = lookup(each.value, "force_destroy", false)

  delegation_set_id = try(var.delegation_set_id, null)

  tags = merge(lookup(each.value, "tags", {}), {
    managedBy   = "Terraform"
  })

}

# -------------------------------------------------------------------------------------------------
#  Zone RecordSet
# -------------------------------------------------------------------------------------------------

# resource "aws_route53_record" "a_record" {
#   for_each  = var.a_records
#   zone_id   = var.zone_id
#   name      = "${each.key}.${data.aws_route53_zone.zone.name}"
#   type      = "A"
#   ttl       = "300"
#   records   = ["10.0.0.1"]
# }

# resource "aws_route53_record" "a_record" {
#   for_each  = var.cname_records
#   zone_id   = var.zone_id
#   name      = "${each.key}.${data.aws_route53_zone.zone.name}"
#   type      = "CNAME"
#   ttl       = "300"
#   records   = [each.value]
# }

