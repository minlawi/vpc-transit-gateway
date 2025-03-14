resource "aws_vpc" "vpc" {
  count                = var.create_vpc ? length(var.cidr_block) : 0
  cidr_block           = var.cidr_block[count.index]
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "vpc-${count.index}"
  }
}

# # Create private subnets for Nginx in VPC-0
resource "aws_subnet" "private_subnets" {
  count                   = var.create_vpc ? length(data.aws_availability_zones.available.names) : 0
  vpc_id                  = aws_vpc.vpc[0].id
  cidr_block              = cidrsubnet(aws_vpc.vpc[0].cidr_block, 4, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false
  tags = {
    Name = "private-subnet-${data.aws_availability_zones.available.names[count.index]}"
  }
}

# # # Create public subnets for Bastion in VPC-1
resource "aws_subnet" "public_subnets" {
  count                   = var.create_vpc ? length(data.aws_availability_zones.available.names) : 0
  vpc_id                  = aws_vpc.vpc[1].id
  cidr_block              = cidrsubnet(aws_vpc.vpc[1].cidr_block, 4, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-${data.aws_availability_zones.available.names[count.index]}"
  }
}

# # Create Tansite Gatway for VPC Peering
resource "aws_ec2_transit_gateway" "tgw" {
  count       = var.create_vpc ? 1 : 0
  description = "Transit Gateway for VPC Peering"
  tags = {
    Name = "tgw-vpc-peering"
  }
}

# # Attach VPC-0 to Transit Gateway
resource "aws_ec2_transit_gateway_vpc_attachment" "tg_vpc_0_attachment" {
  count              = var.create_vpc ? 1 : 0
  subnet_ids         = aws_subnet.private_subnets[*].id
  transit_gateway_id = aws_ec2_transit_gateway.tgw[0].id
  vpc_id             = aws_vpc.vpc[0].id
}

# # Attach VPC-1 to Transit Gateway
resource "aws_ec2_transit_gateway_vpc_attachment" "tg_vpc_1_attachment" {
  count              = var.create_vpc ? 1 : 0
  subnet_ids         = aws_subnet.public_subnets[*].id
  transit_gateway_id = aws_ec2_transit_gateway.tgw[0].id
  vpc_id             = aws_vpc.vpc[1].id
}

# # # NAT Gateway in VPC-1 for Internet Access
resource "aws_eip" "nat_eip" {
  count = var.create_vpc ? 1 : 0
}

resource "aws_nat_gateway" "nat_gateway" {
  count         = var.create_vpc ? 1 : 0
  allocation_id = aws_eip.nat_eip[0].id
  subnet_id     = aws_subnet.public_subnets[1].id
  depends_on    = [aws_internet_gateway.igw]
  tags = {
    Name = "nat-gateway-vpc-1"
  }
}

# Create Internet Gateway for VPC-1
resource "aws_internet_gateway" "igw" {
  count  = var.create_vpc ? 1 : 0
  vpc_id = aws_vpc.vpc[1].id
  tags = {
    Name = "igw-vpc-1"
  }
}

# Route Tables and Routing Information

# Private Route Table in VPC-0
resource "aws_route_table" "private_route_table" {
  count  = var.create_vpc ? 1 : 0
  vpc_id = aws_vpc.vpc[0].id
  tags = {
    Name = "private-route-table-vpc-0"
  }
}

# Create Route Table Association for VPC-0
resource "aws_route_table_association" "private_route_table_association" {
  count          = var.create_vpc ? length(aws_subnet.private_subnets) : 0
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_route_table[0].id
}

resource "aws_route" "private_to_tgw" {
  count                  = var.create_vpc ? 1 : 0
  route_table_id         = aws_route_table.private_route_table[0].id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.tgw[0].id
}

# Create Public Route Table in VPC-1
resource "aws_route_table" "public_route_table" {
  count  = var.create_vpc ? 1 : 0
  vpc_id = aws_vpc.vpc[1].id
  tags = {
    Name = "public-route-table-vpc-1"
  }
}

# Create Route Table Association for VPC-1
resource "aws_route_table_association" "public_route_table_association" {
  count          = var.create_vpc ? length(aws_subnet.public_subnets) : 0
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route_table[0].id
}

# Create Internet Route for Public Route Table
resource "aws_route" "internet_route" {
  count                  = var.create_vpc ? 1 : 0
  route_table_id         = aws_route_table.public_route_table[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw[0].id
}

resource "aws_route" "vpc1_to_vpc0" {
  count                  = var.create_vpc ? 1 : 0
  route_table_id         = aws_route_table.public_route_table[0].id
  destination_cidr_block = aws_vpc.vpc[0].cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.tgw[0].id
}

resource "aws_route" "vpc0_to_vpc1" {
  count                  = var.create_vpc ? 1 : 0
  route_table_id         = aws_route_table.private_route_table[0].id
  destination_cidr_block = aws_vpc.vpc[1].cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.tgw[0].id
}