# Create the VPC
resource "aws_vpc" "vpc_network" {

  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name      = "${var.project}-${var.environment}-vpc"
    managedBy = "Terraform"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

# Create a Public Subnets.
resource "aws_subnet" "public_subnets" {

  count             = var.enable_public_subnet ? var.availability_zones_count : 0
  vpc_id            = aws_vpc.vpc_network.id
  cidr_block        = cidrsubnet(var.vpc_cidr, var.subnet_cidr_bits, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name                     = "${var.project}-${var.environment}-public-subnets"
    "kubernetes.io/role/elb" = 1
    managedBy                = "Terraform"
  }
  map_public_ip_on_launch = true
}

# Create a Private Subnet
resource "aws_subnet" "private_subnets" {

  count             = var.availability_zones_count
  vpc_id            = aws_vpc.vpc_network.id
  cidr_block        = cidrsubnet(var.vpc_cidr, var.subnet_cidr_bits, count.index + var.availability_zones_count)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name                              = "${var.project}-${var.environment}-private-subnets"
    "kubernetes.io/role/internal-elb" = 1
    managedBy                         = "Terraform"
  }
}

# Create Internet Gateway and attach it to VPC
resource "aws_internet_gateway" "this" {

  vpc_id = aws_vpc.vpc_network.id

  tags = {
    Name      = "${var.project}-${var.environment}-igw"
    managedBy = "Terraform"
  }
}

# Route Table(s)
# Route the public subnet traffic through the IGW
resource "aws_route_table" "public_rt" {

  vpc_id = aws_vpc.vpc_network.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name      = "${var.project}-${var.environment}-public-rt"
    managedBy = "Terraform"
  }
}

# Route table Association with Public Subnets
resource "aws_route_table_association" "public_rt_association" {

  count          = var.enable_public_subnet ? var.availability_zones_count : 0
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_rt.id
}


resource "aws_eip" "nat_eip" {

  vpc = true

  tags = {
    Name      = "${var.project}-${var.environment}-ngw-ip"
    managedBy = "Terraform"
  }
}

# Creating the NAT Gateway using subnet_id and allocation_id
resource "aws_nat_gateway" "nat_gw" {

  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnets[0].id

  tags = {
    Name      = "${var.project}-${var.environment}-ngw"
    managedBy = "Terraform"
  }
}

# We created a route table with target as NAT gateway and Associate it to private subnet.
# So that instances in private subnet can also connet to internet. 
# request from instance inside private subnet goes to NAT gateway in public subnet and from NAT gateway it goes to Internet Gateway.
# Route table for Private Subnets
resource "aws_route_table" "private_rt" {

  vpc_id = aws_vpc.vpc_network.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name      = "${var.project}-${var.environment}-private-rt"
    managedBy = "Terraform"
  }
}

# Route table Association with Private Subnets
resource "aws_route_table_association" "private_rt_association" {

  count          = var.availability_zones_count
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_rt.id
}


# Add route to default route table (that comes with VPC by default, no subnets attached, so can be ignored)
resource "aws_route" "default_route" {

  route_table_id         = aws_vpc.vpc_network.default_route_table_id
  nat_gateway_id         = aws_nat_gateway.nat_gw.id
  destination_cidr_block = "0.0.0.0/0"
}
