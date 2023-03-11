module "aws_alb" {
  source = "./modules/aws-alb"

  vpc_id    = module.aws_vpc.vpc_id
  subnets   = module.aws_vpc.public_subnet_id
  bucket    = var.bucket


}