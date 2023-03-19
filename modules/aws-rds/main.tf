locals {

  monitoring_role_arn = var.create_monitoring_role ? aws_iam_role.enhanced_monitoring[0].arn : var.monitoring_role_arn
}

# Ref. https://docs.aws.amazon.com/general/latest/gr/aws-arns-and-namespaces.html#genref-aws-service-namespaces
data "aws_partition" "current" {}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A DATABASE SUBNET GROUP
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_db_subnet_group" "this" {
  count = var.create_db_subnet_group ? 1 : 0

  name        = "${var.identifier}-db-subnet-group"
  description = "DB Subnet Group for ${var.identifier}"
  subnet_ids  = var.subnet_ids

  tags = {
    Name = "${var.identifier}-db-subnet-group"
  }

}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A CUSTOM PARAMETER GROUP AND AN OPTION GROUP FOR CONFIGURABILITY
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_db_option_group" "this" {
  count = var.create_db_option_group ? 1 : 0

  name                 = var.identifier
  engine_name          = var.engine_name
  major_engine_version = var.major_engine_version

  dynamic "option" {
    for_each = var.options
    content {
      option_name                    = option.value.option_name
      port                           = try(option.value.port, null)
      version                        = try(option.value.version, null)
      db_security_group_memberships  = try(option.value.db_security_group_memberships, null)
      vpc_security_group_memberships = try(option.value.vpc_security_group_memberships, null)

      dynamic "option_settings" {
        for_each = try(option.value.option_settings, [])
        content {
          name  = try(option_settings.value.name, null)
          value = try(option_settings.value.value, null)
        }
      }
    }
  }

  timeouts {
    delete = var.db_option_group_timeouts
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.identifier}-db-option-group"
  }
}

resource "aws_db_parameter_group" "this" {
  count = var.create_db_parameter_group ? 1 : 0

  name        = var.identifier
  family      = var.family
  description = "Custom Parameter Group for ${var.family}"

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = try(parameter.value.apply_method, null)
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.identifier}-db-option-group"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A SECURITY GROUP TO ALLOW ACCESS TO THE RDS INSTANCE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "db_instance_sg" {
  name   = "${var.identifier}-sg"
  vpc_id = var.vpc_id

}

resource "aws_security_group_rule" "this" {
  type              = "ingress"
  from_port         = var.port
  to_port           = var.port
  protocol          = "tcp"
  security_group_id = aws_security_group.db_instance_sg.id
  cidr_blocks       = var.cidr_blocks
}

# ----------------------------------------------------------------
# ROOT USER AND PASSWORD SECTION
# ----------------------------------------------------------------

# password with random length
resource "random_integer" "password_length" {

  min = 25
  max = 35
}

## ROOT PASSWORD
resource "random_password" "root_password" {

  length           = random_integer.password_length.result
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE DATABASE INSTANCE (MASTER DB)
# ---------------------------------------------------------------------------------------------------------------------

# URL: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/MySQL.Concepts.VersionMgmt.html
# Find Engine and EngineVersion: aws rds describe-db-engine-versions  --query 'DBEngineVersions[*].{Engine:Engine,EngineVersion:EngineVersion}' | grep -A 2 '"Engine": "mysql"'

resource "aws_db_instance" "master" {
  identifier                 = var.identifier
  engine                     = var.engine
  engine_version             = var.engine_version
  port                       = var.port
  db_name                    = var.db_name
  username                   = var.username
  password                   = random_password.root_password.result
  instance_class             = var.instance_class
  allocated_storage          = var.allocated_storage
  max_allocated_storage      = var.max_allocated_storage
  storage_type               = var.storage_type
  storage_encrypted          = var.storage_encrypted
  replicate_source_db        = var.replicate_source_db
  multi_az                   = var.multi_az
  skip_final_snapshot        = true
  copy_tags_to_snapshot      = false
  publicly_accessible        = false
  license_model              = var.license_model
  db_subnet_group_name       = try(aws_db_subnet_group.this[0].id, null)
  vpc_security_group_ids     = ["${aws_security_group.db_instance_sg.id}"]
  parameter_group_name       = try(aws_db_parameter_group.this[0].id, null)
  option_group_name          = try(aws_db_option_group.this[0].id, null)
  apply_immediately          = var.apply_immediately
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  backup_window              = var.backup_window
  # Backups are required in order to create a replica. backup_retention_period should be grater than 0. Default value is 0.
  backup_retention_period         = var.backup_retention_period
  maintenance_window              = var.maintenance_window
  deletion_protection             = var.deletion_protection
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null
  performance_insights_kms_key_id       = var.performance_insights_enabled ? var.performance_insights_kms_key_id : null

  tags = {
    Name = var.identifier
  }

  timeouts {
    create = lookup(var.timeouts, "create", null)
    delete = lookup(var.timeouts, "delete", null)
    update = lookup(var.timeouts, "update", null)
  }

}

# ---------------------------------------------------------------------------------------------------------------------
# STORE THE RDS INSTANCE PASSWORD TO AWS SECRETS MANAGER
# ---------------------------------------------------------------------------------------------------------------------

# create AWS secrets manager secret ID
resource "aws_secretsmanager_secret" "this" {

  name = "AWS_RDS_${upper(replace(aws_db_instance.master.identifier, "-", "_"))}_${upper(replace(aws_db_instance.master.username, "-", "_"))}_PASSWORD"
  # Number of days that AWS Secrets Manager waits before it can delete the secret.
  # This value can be 0 to force deletion. Default is 30 days
  recovery_window_in_days = 0

  depends_on = [
    aws_db_instance.master,
  ]

}

# store secret key data to AWS secrets manager secret ID
resource "aws_secretsmanager_secret_version" "this" {

  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = random_password.root_password.result
}

################################################################################
# Enhanced monitoring
################################################################################

data "aws_iam_policy_document" "enhanced_monitoring" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "enhanced_monitoring" {
  count = var.create_monitoring_role ? 1 : 0

  name               = var.monitoring_role_name
  assume_role_policy = data.aws_iam_policy_document.enhanced_monitoring.json

  tags = {
    "Name" = var.monitoring_role_name
  }
}

resource "aws_iam_role_policy_attachment" "enhanced_monitoring" {
  count = var.create_monitoring_role ? 1 : 0

  role       = aws_iam_role.enhanced_monitoring[0].name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}


################################################################################
# Replica DB
################################################################################

resource "aws_db_instance" "replica" {
  count = var.create_db_instance_replica ? 1 : 0

  identifier = "${var.identifier}-replica"
  # some issues with AWS TF Provider: https://github.com/hashicorp/terraform-provider-aws/pull/25439
  # engine and engine_version can not be specified for replica instance
  # engine                          = var.engine
  # engine_version                  = var.engine_version
  port = var.port

  # Username and password should not be set for replicas
  username = null
  password = null

  availability_zone     = "${var.region}b"
  instance_class        = var.instance_class
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = var.storage_encrypted

  # Source database. For cross-region use db_instance_arn
  replicate_source_db = aws_db_instance.master.id

  multi_az                        = false
  skip_final_snapshot             = true
  copy_tags_to_snapshot           = false
  publicly_accessible             = false
  license_model                   = var.license_model
  db_subnet_group_name            = ""
  vpc_security_group_ids          = ["${aws_security_group.db_instance_sg.id}"]
  parameter_group_name            = try(aws_db_parameter_group.this[0].id, null)
  option_group_name               = try(aws_db_option_group.this[0].id, null)
  apply_immediately               = var.apply_immediately
  auto_minor_version_upgrade      = var.auto_minor_version_upgrade
  backup_window                   = var.backup_window
  backup_retention_period         = 0
  maintenance_window              = var.maintenance_window
  deletion_protection             = var.deletion_protection
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null
  performance_insights_kms_key_id       = var.performance_insights_enabled ? var.performance_insights_kms_key_id : null


  tags = {
    Name = var.identifier
  }

  timeouts {
    create = lookup(var.timeouts, "create", null)
    delete = lookup(var.timeouts, "delete", null)
    update = lookup(var.timeouts, "update", null)
  }

  depends_on = [
    aws_db_instance.master,
  ]

}
