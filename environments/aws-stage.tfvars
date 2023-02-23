# common variables
# ----------------------------------------------------------------
project         = "heute"
environment     = "stage"
region          = "eu-west-1"

# VPC Config
# ----------------------------------------------------------------
enable_public_subnet      = true
availability_zones_count  = 2
vpc_cidr                  = "10.0.0.0/16"
subnet_cidr_bits          = 8

# Route53 Config
# ----------------------------------------------------------------
# public zone configuration
# ----------------------------------------------------------------

public_zone_name    = "public.local.com"   
public_zone_comment = "public hosted zone for public.local.com"
public_zone_tags = {
    Name = "public-local-com-public-zone"
}

public_zone_a_records   = {
    "test-1" = ["10.0.1.1"]
    "test-2" = ["10.0.2.1"]
}

public_zone_cname_records = {
    "test-3" = ["test.example.com"]
}

public_zone_nameservers = {
    "test" = [
        "abc.ns.com",
        "xyz.ns.com",
    ]
}

public_zone_aliases = [
    {
        "name"          = "cloud-storage"
        "alias_zone_id" = "Z215JYRZR1TBD5"
        "alias_name"    = "elb-ffm-dev-1741466132.eu-central-1.elb.amazonaws.com."
        "type"          = "A"
    }
]

# private zone configuration
private_zone_name    = "private.local.com"   
private_zone_comment = "private.local.com private hosted zone"
private_zone_tags = {
    Name = "private-local-com-private-zone"
}

private_zone_a_records   = {
    "test-5" = ["10.0.5.1"]
    "test-6" = ["10.0.6.1"]
}

private_zone_cname_records = {
    "test-7" = ["private.example.com"]
}   
  
private_zone_nameservers = {
    "test" = [
        "abc.ns.com",
        "xyz.ns.com",
    ]
}

private_zone_aliases = [
    {
        "name"          = "cloudfront"
        "alias_name"    = "elb-ffm-dev-1741466132.eu-central-1.elb.amazonaws.com."
        "alias_zone_id" = "Z215JYRZR1TBD5"
        "type"          = "A"
    }
]

# IAM Config
# --------------------------------------------------------------------------------
# Account Management
# --------------------------------------------------------------------------------

account_alias = "stage-account"

account_pass_policy = {
  manage                         = true
  allow_users_to_change_password = true
  hard_expiry                    = false
  max_password_age               = 365
  minimum_password_length        = 8
  password_reuse_prevention      = 5
  require_lowercase_characters   = true
  require_numbers                = true
  require_symbols                = true
  require_uppercase_characters   = true
}

# --------------------------------------------------------------------------------
# AWS KMS Config
# --------------------------------------------------------------------------------
use_aws_key_material    = false
kms_alias               = "alias/secrets"

# --------------------------------------------------------------------------------
# AWS RDS Config
# --------------------------------------------------------------------------------
# RDS Instance Engine Version reference: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/MySQL.Concepts.VersionMgmt.html 
rds_instances   = [
    {
        identifier              = "heute-landingpage"
        engine                  = "mysql"
        # aws rds describe-db-engine-versions --default-only --engine mysql
        engine_version          = "8.0.32"
        port                    = "3306"
        db_name                 = "heute"
        username                = "root"
        allocated_storage       = "5"
        max_allocated_storage   = "10"
        cidr_blocks = [
            "10.0.0.0/16",
        ]
        family           = "mysql8.0"
        # parameters   = [
        #     {
        #         name    = "general_log"
        #         value   = "1"
        #     }
        # ]
        create_db_parameter_group   = false
        create_db_instance_replica  = true
        backup_retention_period     = 1
        # DB subnet group is not necessary for master-replica setup. set to FALSE
        create_db_subnet_group      = true
        deletion_protection         = false
        apply_immediately           = true
    },
    {
        identifier              = "heute-web"
        engine                  = "postgres"
        # aws rds describe-db-engine-versions --default-only --engine postgre
        engine_version          = "14.6"
        port                    = "5432"
        db_name                 = "heute"
        username                = "postgres"
        allocated_storage       = "5"
        max_allocated_storage   = "10"
        cidr_blocks = [
            "10.0.0.0/16",
        ]
        family           = "postgres14"
        # parameters   = [
        #     {
        #         name    = "general_log"
        #         value   = "1"
        #     }
        # ]
        create_db_parameter_group   = false
        create_db_instance_replica  = true
        backup_retention_period     = 1
        # DB subnet group is not necessary for master-replica setup. set to FALSE
        create_db_subnet_group      = true
        deletion_protection         = false
        apply_immediately           = true       
    }
]
