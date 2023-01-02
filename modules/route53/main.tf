resource "aws_route53_delegation_set" "delegation_sets" {
  count = length
  reference_name = "DynDNS"
}

resource "aws_route53_zone" "this" {
  for_each = { for k, v in var.zones : k => v }

  name          = lookup(each.value, "domain_name", each.key)
  comment       = lookup(each.value, "comment", null)
  force_destroy = lookup(each.value, "force_destroy", false)

  # for public DNS Zones
  delegation_set_id = lookup(each.value, "delegation_set_id", null)
  # for private DNS Zones
  dynamic "vpc" {
    for_each = try(tolist(lookup(each.value, "vpc", [])), [lookup(each.value, "vpc", {})])

    content {
      vpc_id     = vpc.value.vpc_id
      vpc_region = lookup(vpc.value, "vpc_region", null)
    }
  }

  tags = {
    name        = "${aws_route53_zone.this.name}-route53-zone"
    managedBy   = "Terraform"
  }

}