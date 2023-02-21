# ---------------------------------------------------------------------------------------------------------------------
# CREATE A DATABASE SUBNET GROUP
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_db_subnet_group" "this" {
  count = var.create_db_subnet_group ? 1 : 0

  name        = "${var.project}-${var.environment}-db-subnet-group"
  description = "DB Subnet Group for ${var.environment} Environment"
  subnet_ids  = var.subnet_ids

  tags = {
      Name = "${var.project}-${var.environment}-db-subnet-group"
    }

}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A CUSTOM PARAMETER GROUP AND AN OPTION GROUP FOR CONFIGURABILITY
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_db_option_group" "this" {
  count = var.create_db_option_group ? 1 : 0
  
  name                     = var.name
  engine_name              = var.engine_name
  major_engine_version     = var.major_engine_version

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

  tags  = {
    Name = "${var.name}-db-option-group"
  }
}

resource "aws_db_parameter_group" "this" {
  count = var.create_db_parameter_group ? 1 : 0

  name        = var.name
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

  tags  = {
    Name = "${var.name}-db-option-group"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A SECURITY GROUP TO ALLOW ACCESS TO THE RDS INSTANCE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "db_instance_sg" {
  name   = "${var.name}-sg"
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
# CREATE THE DATABASE INSTANCE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_db_instance" "this" {
  identifier              = var.name
  engine                  = var.engine_name
  engine_version          = var.engine_version
  port                    = var.port
  name                    = var.database_name
  username                = var.username
  password                = random_password.root_password.result
  instance_class          = var.instance_class
  allocated_storage       = var.allocated_storage
  skip_final_snapshot     = true
  license_model           = var.license_model
  db_subnet_group_name    = aws_db_subnet_group.this.id
  vpc_security_group_ids  = ["${aws_security_group.db_instance_sg.id}"]
  publicly_accessible     = false
  parameter_group_name    = aws_db_parameter_group.this.id
  option_group_name       = aws_db_option_group.this.id

  tags {
    Name = var.name
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# STORE THE RDS INSTANCE PASSWORD TO AWS SECRETS MANAGER
# ---------------------------------------------------------------------------------------------------------------------

# create AWS secrets manager secret ID
resource "aws_secretsmanager_secret" "this" {

  name = AWS_RDS_${upper(replace(var.database_instance_name, "-", "_"))}_PASSWORD
}

# store secret key data to AWS secrets manager secret ID
resource "aws_secretsmanager_secret_version" "this" {

  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = random_password.root_password.result
}