# Create VPC for public subnet
resource "aws_vpc" "vpc_public" {
  count                = var.create_vpc ? 1 : 0
  cidr_block           = var.cidr_block[1]
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "vpc-public"
  }
}

# Create public subnet
resource "aws_subnet" "subnet_public" {
  count                   = var.create_vpc ? length(data.aws_availability_zones.available.names) : 0
  vpc_id                  = aws_vpc.vpc_public[0].id
  cidr_block              = cidrsubnet(aws_vpc.vpc_public[0].cidr_block, 4, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-${count.index}-${data.aws_availability_zones.available.names[count.index]}"
  }
}

# Create public route table
resource "aws_route_table" "route_table_public" {
  count  = var.create_vpc ? 1 : 0
  vpc_id = aws_vpc.vpc_public[0].id
  tags = {
    Name = "public-route-table"
  }
}

# Associate public subnet with public route table
resource "aws_route_table_association" "route_table_association_public" {
  count          = var.create_vpc ? length(aws_subnet.subnet_public) : 0
  subnet_id      = aws_subnet.subnet_public[count.index].id
  route_table_id = aws_route_table.route_table_public[0].id
}

# Create internet gateway
resource "aws_internet_gateway" "internet_gateway" {
  count  = var.create_vpc ? 1 : 0
  vpc_id = aws_vpc.vpc_public[0].id
  tags = {
    Name = "vpc-public-igw"
  }
}

# Create Default Route for Public Subnet via Internet Gateway
resource "aws_route" "default_route_public_rt" {
  count                  = var.create_vpc ? 1 : 0
  route_table_id         = aws_route_table.route_table_public[0].id
  destination_cidr_block = local.all_cidr_blocks
  gateway_id             = aws_internet_gateway.internet_gateway[0].id
}

# Create VPC Private Route via Transit Gateway
resource "aws_route" "route_vpc_private_public_rt" {
  count                  = var.create_vpc ? 1 : 0
  route_table_id         = aws_route_table.route_table_public[0].id
  destination_cidr_block = aws_vpc.vpc_private[0].cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.tgw[0].id
}

# Create Public Subnet for NAT Gateway
resource "aws_subnet" "subnet_nat" {
  count                   = var.create_vpc ? 1 : 0
  vpc_id                  = aws_vpc.vpc_public[0].id
  cidr_block              = cidrsubnet(aws_vpc.vpc_public[0].cidr_block, 4, count.index + 3)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "nat-subnet-${count.index}-${data.aws_availability_zones.available.names[count.index]}"
  }
}

# Create NAT Route Table
resource "aws_route_table" "route_table_nat" {
  count  = var.create_vpc ? 1 : 0
  vpc_id = aws_vpc.vpc_public[0].id
  tags = {
    Name = "nat-route-table"
  }
}

# Associate NAT Subnet with NAT Route Table
resource "aws_route_table_association" "route_table_association_nat" {
  count          = var.create_vpc ? length(aws_subnet.subnet_nat) : 0
  subnet_id      = aws_subnet.subnet_nat[count.index].id
  route_table_id = aws_route_table.route_table_nat[0].id
}

# Create EIP for NAT Gateway
resource "aws_eip" "eip_nat" {
  count      = var.create_vpc ? 1 : 0
  depends_on = [aws_internet_gateway.internet_gateway]
  tags = {
    Name = "nat-eip"
  }
}

# Create Public NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  count         = var.create_vpc ? 1 : 0
  allocation_id = aws_eip.eip_nat[0].id
  subnet_id     = aws_subnet.subnet_public[count.index].id
  depends_on    = [aws_internet_gateway.internet_gateway]
  tags = {
    Name = "nat-gateway"
  }
}

# Create Default Route in NAT Route Table via NAT Gateway
resource "aws_route" "default_route_nat_rt" {
  count                  = var.create_vpc ? 1 : 0
  route_table_id         = aws_route_table.route_table_nat[0].id
  destination_cidr_block = local.all_cidr_blocks
  nat_gateway_id         = aws_nat_gateway.nat_gateway[0].id
}

# Create VPC Private Route in NAT Route Table via Transit Gateway
resource "aws_route" "route_vpc_private_nat_rt" {
  count                  = var.create_vpc ? 1 : 0
  depends_on             = [aws_ec2_transit_gateway.tgw]
  route_table_id         = aws_route_table.route_table_nat[0].id
  destination_cidr_block = aws_vpc.vpc_private[0].cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.tgw[0].id
}