# Create VPC for private subnet
resource "aws_vpc" "vpc_private" {
  count                = var.create_vpc ? 1 : 0
  cidr_block           = var.cidr_block[0]
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "vpc-private"
  }
}

# Create private subnet
resource "aws_subnet" "subnet_private" {
  count             = var.create_vpc ? length(data.aws_availability_zones.available.names) : 0
  vpc_id            = aws_vpc.vpc_private[0].id
  cidr_block        = cidrsubnet(aws_vpc.vpc_private[0].cidr_block, 4, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "private-subnet-${count.index}-${data.aws_availability_zones.available.names[count.index]}"
  }
}

# Create private route table
resource "aws_route_table" "route_table_private" {
  count  = var.create_vpc ? 1 : 0
  vpc_id = aws_vpc.vpc_private[0].id
  tags = {
    Name = "private-route-table"
  }
}

# Associate private subnet with private route table
resource "aws_route_table_association" "route_table_association_private" {
  count          = var.create_vpc ? length(aws_subnet.subnet_private) : 0
  subnet_id      = aws_subnet.subnet_private[count.index].id
  route_table_id = aws_route_table.route_table_private[0].id
}

# Create Default Route for Private Subnet via Transit Gateway
resource "aws_route" "route_private" {
  count                  = var.create_vpc ? 1 : 0
  route_table_id         = aws_route_table.route_table_private[0].id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.tgw[0].id
}