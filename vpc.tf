module "aws_vpc" {
    source = "./modules/vpc"

    enable_public_subnet        = var.enable_public_subnet
    availability_zones_count    = var.availability_zones_count
    vpc_cidr                    = var.vpc_cidr
    subnet_cidr_bits            = var.subnet_cidr_bits
  
}