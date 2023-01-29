locals {
  security_group_data = yamldecode(file("./etc/security-groups.yaml")) 

  inbound_rules   = flatten([for security_group in local.security_group_data.security_groups : [
      for inbound_rule in try(security_group.inbound_rules, []) : {
        name        = security_group.name
        from_port   = inbound_rule.from_port
        to_port     = inbound_rule.to_port
        protocol    = inbound_rule.protocol
        cidr_blocks = inbound_rule.cidr_blocks
      }
    ]
  ])

  outbound_rules   = flatten([for security_group in local.security_group_data.security_groups : [
      for outbound_rule in security_group.outbound_rules : {
        name        = security_group.name
        from_port   = try(outbound_rule.from_port, 0)
        to_port     = try(outbound_rule.to_port, 0)
        protocol    = try(outbound_rule.protocol, "-1")
        cidr_blocks = try(outbound_rule.cidr_blocks, ["0.0.0.0/0"])
      }
    ]
  ])
}
resource "aws_security_group" "this" {
  for_each = { for security_group in local.security_group_data.security_groups : security_group.name => security_group }

  name          = each.value.name
  description   = each.value.description
  vpc_id        = var.vpc_id
 
  tags = {
    Name        = each.value.name
    environment = var.environment
    Project     = var.project
    ManagedBy   = "terraform"
  }
}

resource "aws_security_group_rule" "ingress" {
  for_each =  { for idx, record in local.inbound_rules : idx => record }

  type              = "ingress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = each.value.cidr_blocks
  security_group_id = aws_security_group.this[each.value.name].id
}

resource "aws_security_group_rule" "egress" {
  for_each =  { for idx, record in local.outbound_rules : idx => record }

  type        = "egress"
  from_port   = each.value.from_port
  to_port     = each.value.to_port
  protocol    = each.value.protocol
  cidr_blocks = each.value.cidr_blocks
  security_group_id = aws_security_group.this[each.value.name].id
}
 
