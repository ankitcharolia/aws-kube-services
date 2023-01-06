# By default, Route 53 assigns a random selection of name servers to each new hosted zone. 
# A set of four authoritative name servers that you can use with more than one hosted zone. 
# To make it easier to migrate DNS service to Route 53 for a large number of domains, 
# you can create a reusable delegation set and then associate the reusable delegation set with new hosted zones.
# -------------------------------------------------------------------------------------------------
# Delegation sets
# -------------------------------------------------------------------------------------------------
resource "aws_route53_delegation_set" "delegation_sets" {
  count = var.public_zones != null ? 1: 0
  reference_name = "DynDNS"
}

# -------------------------------------------------------------------------------------------------
# Public root zones
# -------------------------------------------------------------------------------------------------
resource "aws_route53_zone" "public" {
  for_each = try({ for k, v in var.public_zones : k => v }, tomap({}))

  name          = lookup(each.value, "domain_name", each.key)
  comment       = lookup(each.value, "comment", null)
  force_destroy = lookup(each.value, "force_destroy", false)

  # for public DNS Zones
  delegation_set_id = aws_route53_delegation_set.delegation_sets.id

  tags = {
    name        = "${aws_route53_zone.this.name}-public-zone"
    managedBy   = "Terraform"
  }

}

# -------------------------------------------------------------------------------------------------
# Private root zones
# -------------------------------------------------------------------------------------------------

resource "aws_route53_zone" "private" {
  for_each = try({ for k, v in var.private_zones : k => v }, tomap({}))

  name          = lookup(each.value, "domain_name", each.key)
  comment       = lookup(each.value, "comment", null)
  force_destroy = lookup(each.value, "force_destroy", false)

  # for private DNS Zones
  dynamic "vpc" {
    for_each = try(tolist(lookup(each.value, "vpc", [])), [lookup(each.value, "vpc", {})])

    content {
      vpc_id     = vpc.value.vpc_id
      vpc_region = lookup(vpc.value, "vpc_region", var.region)
    }
  }

  tags = {
    name        = "${aws_route53_zone.this.name}-private-zone"
    managedBy   = "Terraform"
  }

}

# -------------------------------------------------------------------------------------------------
#  Zone RecordSet
# -------------------------------------------------------------------------------------------------

resource "aws_route53_record" "a_record" {
  for_each  = var.a_records
  zone_id   = var.zone_id
  name      = "${each.key}.${data.aws_route53_zone.zone.name}"
  type      = "A"
  ttl       = "300"
  records   = ["10.0.0.1"]
}

resource "aws_route53_record" "a_record" {
  for_each  = var.cname_records
  zone_id   = var.zone_id
  name      = "${each.key}.${data.aws_route53_zone.zone.name}"
  type      = "CNAME"
  ttl       = "300"
  records   = [each.value]
}