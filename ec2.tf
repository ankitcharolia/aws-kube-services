module "aws_ec2" {
  source = "./modules/ec2"

  subnet_id = module.aws_vpc.public_subnet_id[0]
  vpc_id    = module.aws_vpc.vpc_id
  project   = var.project
  zone_id   = module.aws_public_route53.route53_public_zone_id
  dns_name  = module.aws_public_route53.route53_public_zone_name

  depends_on = [
    module.aws_vpc,
    module.aws_public_route53,
  ]

}