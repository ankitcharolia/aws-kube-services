# common variables
project       = "heute"
environment   = "stage"
region        = "eu-west-1"

# VPC Config
enable_public_subnet      = true
availability_zones_count  = 2
vpc_cidr                  = "10.0.0.0/16"
subnet_cidr_bits          = 8

# Route53 Config
