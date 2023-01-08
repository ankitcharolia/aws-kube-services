# By default, Route 53 assigns a random selection of name servers to each new hosted zone. 
# A set of four authoritative name servers that you can use with more than one hosted zone. 
# To make it easier to migrate DNS service to Route 53 for a large number of domains, 
# you can create a reusable delegation set and then associate the reusable delegation set with new hosted zones.

resource "aws_route53_delegation_set" "this" {
  for_each = try(var.delegation_sets, tomap({}))

  reference_name = lookup(each.value, "reference_name", null)
}