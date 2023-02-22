module "aws_rds" {
  for_each = { for rds_instance in var.rds_instances : rds_instance.name => rds_instance }
  
  source = "./modules/aws-rds"

  project                   = var.project
  environment               = var.environment
  vpc_id                    = module.aws_vpc.vpc_id
  subnet_ids                = module.aws_vpc.private_subnet_id
  name                      = each.value.name
  engine                    = each.value.engine
  engine_version            = each.value.engine_version
  port                      = each.value.port
  db_name                   = each.value.db_name
  username                  = each.value.username
  allocated_storage         = each.value.allocated_storage
  max_allocated_storage     = each.value.max_allocated_storage
  cidr_blocks               = each.value.cidr_blocks
  family                    = each.value.family
  parameters                = each.value.parameters
  create_db_parameter_group = each.value.create_db_parameter_group


 depends_on = [
   module.aws_vpc,
 ]

}