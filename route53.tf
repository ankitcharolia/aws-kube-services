module "aws_public_route53" {
    source = "./modules/route53-public"

    public_zone_name    = var.public_zone_name
    public_zone_comment = var.public_zone_comment
    public_zone_tags    = var.public_zone_tags
    delegation_set_id   = module.aws_delegation_sets.route53_delegation_set_id["DynDNS"]

    public_zone_a_records     = var.public_zone_a_records
    public_zone_cname_records = var.public_zone_cname_records
    public_zone_nameservers   = var.public_zone_nameservers
  depends_on = [
    module.aws_delegation_sets,
  ]
}

module "aws_private_route53" {
    source = "./modules/route53-private"

    private_zone_name     = var.private_zone_name
    private_zone_comment  = var.private_zone_comment
    private_zone_tags     = var.private_zone_tags
    vpc_id  = [
      module.aws_vpc.vpc_id,
    ]
  
    
    private_zone_a_records      = var.private_zone_a_records
    private_zone_cname_records  = var.private_zone_cname_records
    private_zone_nameservers    = var.private_zone_nameservers
    region                      = var.region

  depends_on = [
    module.aws_vpc,
  ]
}