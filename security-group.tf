module "aws_security_group" {
    source = "./modules/security-group"

    project     = var.project

    vpc_id  = module.aws_vpc.vpc_id
  

  depends_on = [
    module.aws_vpc,
  ]
}