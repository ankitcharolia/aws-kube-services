module "aws_public_route53" {
    source = "./modules/route53-public"

    public_zones      = var.public_zones
    delegation_set_id = module.aws_delegation_sets.route53_delegation_set_id["DynDNS"]

  depends_on = [
    module.aws_delegation_sets,
  ]
}

module "aws_private_route53" {
    source = "./modules/route53-private"

    private_zones = var.private_zones
    vpc_id        = [
      module.aws_vpc.vpc_id,
    ]
    region        = var.region

  depends_on = [
    module.aws_vpc,
  ]
}