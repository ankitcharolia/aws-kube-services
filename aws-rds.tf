module "aws_rds" {
  for_each = { for rds_instance in var.rds_instances : rds_instance.name => rds_instance }
  
  source = "./modules/aws-rds"

  project     = var.project
  environment = var.environment
  vpc_id      = module.aws_vpc.vpc_id
  subnet_ids  = module.aws_vpc.private_subnet_id
  name        = each.value.name


 depends_on = [
   module.aws_vpc,
 ]

}