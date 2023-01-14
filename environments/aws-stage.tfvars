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
# public zone configuration

public_zone_name    = "public.local.com"   
public_zone_comment = "public hosted zone for public.local.com"
public_zone_tags = {
    Name = "public-local-com-public-zone"
}

public_zone_a_records   = {
    "test-1" = "10.0.1.1"
    "test-2" = "10.0.2.1"
}

public_zone_cname_records = {
    "test-3" = "test.example.com"
}

public_zone_nameservers = {
    "test" = [
        "abc.ns.com",
        "xyz.ns.com",
    ]
}

# private zone configuration
private_zone_name    = "private.local.com"   
private_zone_comment = "private.local.com private hosted zone"
private_zone_tags = {
    Name = "private-local-com-private-zone"
}

private_zone_a_records   = {
    "test-5" = "10.0.5.1"
    "test-6" = "10.0.6.1"
}

private_zone_cname_records = {
    "test-7" = "private.example.com"
}   
  
private_zone_nameservers = {
    "test" = [
        "abc.ns.com",
        "xyz.ns.com",
    ]
}