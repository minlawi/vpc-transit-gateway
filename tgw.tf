# Create Transit Gateway
resource "aws_ec2_transit_gateway" "tgw" {
  count                           = var.create_vpc ? 1 : 0
  description                     = "Transit Gateway for VPC Peerings"
  default_route_table_association = local.disable
  default_route_table_propagation = local.disable
  tags = {
    Name = "Transit Gateway"
  }
}

# Transit Gateway Attachment for Private Subnets of Private VPC
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_private_vpc_attachment" {
  count              = var.create_vpc ? 1 : 0
  subnet_ids         = tolist(aws_subnet.subnet_private[*].id)
  transit_gateway_id = aws_ec2_transit_gateway.tgw[0].id
  vpc_id             = aws_vpc.vpc_private[0].id
  tags = {
    Name = "tgw-private-vpc-attachment"
  }
}

# Transite Gateway Attachment for NAT subnets of Public VPC
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_public_vpc_attachment" {
  count              = var.create_vpc ? 1 : 0
  subnet_ids         = tolist(aws_subnet.subnet_nat[*].id)
  transit_gateway_id = aws_ec2_transit_gateway.tgw[0].id
  vpc_id             = aws_vpc.vpc_public[0].id
  tags = {
    Name = "tgw-public-vpc-attachment"
  }
}

# Transit Gateway Route Table
resource "aws_ec2_transit_gateway_route_table" "tgw_route_table" {
  count              = var.create_vpc ? 1 : 0
  transit_gateway_id = aws_ec2_transit_gateway.tgw[0].id
  tags = {
    Name = "tgw-route-table"
  }
}

# Transit Gateway Route Table Association for Private VPC
resource "aws_ec2_transit_gateway_route_table_association" "tgw_route_table_association_private_vpc" {
  count                          = var.create_vpc ? 1 : 0
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_route_table[0].id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_private_vpc_attachment[0].id
}

# Transit Gateway Route Table Association for Public VPC
resource "aws_ec2_transit_gateway_route_table_association" "tgw_route_table_association_public_vpc" {
  count                          = var.create_vpc ? 1 : 0
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_route_table[0].id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_public_vpc_attachment[0].id
}

# Transit Gateway Route Table Propagation for Private VPC
resource "aws_ec2_transit_gateway_route_table_propagation" "tgw_route_table_propagation_private_vpc" {
  count                          = var.create_vpc ? 1 : 0
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_route_table[0].id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_private_vpc_attachment[0].id
}

# Transit Gateway Route Table Propagation for Public VPC
resource "aws_ec2_transit_gateway_route_table_propagation" "tgw_route_table_propagation_public_vpc" {
  count                          = var.create_vpc ? 1 : 0
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_route_table[0].id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_public_vpc_attachment[0].id
}

# Transit Gateway Default Route
resource "aws_ec2_transit_gateway_route" "tgw_route" {
  count                          = var.create_vpc ? 1 : 0
  destination_cidr_block         = local.all_cidr_blocks
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_route_table[0].id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_public_vpc_attachment[0].id
}

# Transit Gateway Route for Private VPC
resource "aws_ec2_transit_gateway_route" "tgw_route_private_vpc" {
  count                          = var.create_vpc ? 1 : 0
  destination_cidr_block         = aws_vpc.vpc_private[0].cidr_block
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_route_table[0].id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_private_vpc_attachment[0].id
}

# Transit Gateway Route for Public VPC
resource "aws_ec2_transit_gateway_route" "tgw_route_public_vpc" {
  count                          = var.create_vpc ? 1 : 0
  destination_cidr_block         = aws_vpc.vpc_public[0].cidr_block
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_route_table[0].id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_public_vpc_attachment[0].id
}