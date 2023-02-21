module "aws_rds" {
  for_each = { for rds_instance in var.rds_instances : rds_instance.name => rds_instance }
  
  source = "./modules/aws-rds"

  project     = var.project
  environment = var.environment
  vpc_id      = module.aws_vpc.vpc_id
  subnet_ids  = module.aws_vpc.private_subnet_id
  name        = each.value.db_name
  port        = each.value.db_port
  cidr_blocks = each.value.db_cidr_blocks
  family      = each.value.db_family
  parameters  = each.value.db_parameters 
  create_db_parameter_group = each.value.create_db_parameter_group


 depends_on = [
   module.aws_vpc,
 ]

}