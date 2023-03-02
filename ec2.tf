module "aws_ec2" {
  source = "./modules/ec2"

  subnet_id = module.aws_vpc.public_subnet_id[0]

  depends_on = [
    module.aws_vpc,
    module.aws_public_route53,
  ]

}