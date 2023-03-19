module "aws_rds" {
  for_each = { for rds_instance in var.rds_instances : rds_instance.identifier => rds_instance }

  source = "./modules/aws-rds"

  project                      = var.project
  region                       = var.region
  environment                  = var.environment
  vpc_id                       = module.aws_vpc.vpc_id
  subnet_ids                   = module.aws_vpc.private_subnet_id
  identifier                   = each.value.identifier
  engine                       = each.value.engine
  engine_version               = each.value.engine_version
  family                       = each.value.family
  port                         = each.value.port
  db_name                      = each.value.db_name
  username                     = each.value.username
  cidr_blocks                  = each.value.cidr_blocks
  allocated_storage            = each.value.allocated_storage
  max_allocated_storage        = each.value.max_allocated_storage
  instance_class               = try(each.value.instance_class, "db.t3.micro")
  storage_type                 = try(each.value.storage_type, "gp2")
  storage_encrypted            = try(each.value.storage_encrypted, false)
  apply_immediately            = try(each.value.apply_immediately, false)
  auto_minor_version_upgrade   = try(each.value.auto_minor_version_upgrade, false)
  parameters                   = try(each.value.parameters, [])
  create_db_parameter_group    = try(each.value.create_db_parameter_group, false)
  backup_retention_period      = try(each.value.backup_retention_period, null)
  backup_window                = try(each.value.backup_window, null)
  maintenance_window           = try(each.value.maintenance_window, null)
  deletion_protection          = try(each.value.deletion_protection, false)
  multi_az                     = try(each.value.multi_az, true)
  performance_insights_enabled = try(each.value.performance_insights_enabled, false)
  create_db_instance_replica   = try(each.value.create_db_instance_replica, false)
  create_db_subnet_group       = try(each.value.create_db_subnet_group, false)

  depends_on = [
    module.aws_vpc,
  ]

}