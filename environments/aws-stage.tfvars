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
public_zones = {
    "stage.local.com" = {   
        comment = "stage.local.com public zone (stage)",
        tags = {
            Name = "stage-local-com-public-zone"
        }
    }
    "test.local.com" = {
        comment = "test.local.com public zone (test)",
        tags = {
            Name = "test-local-com-public-zone"
        }
    }
}

private_zones = {
    "private.local.com" = {   
        comment = "private.local.com public zone (stage)",
        tags = {
            Name = "private-local-com-public-zone"
        }
    }

}   
    
  