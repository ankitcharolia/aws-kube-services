# Create the VPC
resource "aws_vpc" "vpc_network" {
  cidr_block           = var.main_vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "${var.project}-${var.environment}-vpc",
  }
}

# Create a Public Subnets.
resource "aws_subnet" "publicsubnets" {
  count = var.enable_public_subnet ? 1 : 0
  vpc_id =  aws_vpc.vpc_network.id
  cidr_block = var.public_subnets
 }

# Create a Private Subnet
resource "aws_subnet" "privatesubnets" {
  vpc_id =  aws_vpc.vpc_network.id
  cidr_block = var.private_subnets
}

# Create Internet Gateway and attach it to VPC
resource "aws_internet_gateway" "IGW" {
  vpc_id =  aws_vpc.vpc_network.id
}

# Route table for Public Subnet's
resource "aws_route_table" "PublicRT" {
  vpc_id =  aws_vpc.Main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
   }
}

# Route table for Private Subnet's
resource "aws_route_table" "PrivateRT" {
  vpc_id = aws_vpc.Main.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NATgw.id
  }
}

# Route table Association with Public Subnet's
resource "aws_route_table_association" "PublicRTassociation" {
  subnet_id = aws_subnet.publicsubnets.id
  route_table_id = aws_route_table.PublicRT.id
}

# Route table Association with Private Subnet's
resource "aws_route_table_association" "PrivateRTassociation" {
  subnet_id = aws_subnet.privatesubnets.id
  route_table_id = aws_route_table.PrivateRT.id
}

resource "aws_eip" "nateIP" {
  vpc   = true
}

# Creating the NAT Gateway using subnet_id and allocation_id
resource "aws_nat_gateway" "NATgw" {
  allocation_id = aws_eip.nateIP.id
  subnet_id = aws_subnet.publicsubnets.id
}
