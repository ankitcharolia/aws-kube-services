resource "random_shuffle" "subnet" {
  input        = [module.aws_vpc.public_subnet_id[0], module.aws_vpc.public_subnet_id[1]]
  result_count = 2

  depends_on = [
    module.aws_vpc,
  ]
}

module "aws_ec2" {
  source = "./modules/ec2"

  subnet_id = module.aws_vpc.public_subnet_id[0]
  vpc_id    = module.aws_vpc.vpc_id
  project   = var.project

  depends_on = [
    module.aws_vpc,
    module.aws_public_route53,
  ]

}