resource "aws_security_group" "vpc_public_sg" {
  count  = var.create_vpc ? 1 : 0
  vpc_id = aws_vpc.vpc_public[0].id
  name   = "vpc-public-sg"
  tags = {
    Name = "vpc-public-sg"
  }
}

resource "aws_security_group_rule" "vpc_public_allows_all_ingress" {
  count             = var.create_vpc ? 1 : 0
  type              = local.inbound
  from_port         = local.all_ports
  to_port           = local.all_ports
  protocol          = local.all_protocols
  security_group_id = aws_security_group.vpc_public_sg[0].id
  cidr_blocks       = local.all_cidr_blocks
  description       = "Allow all ingress traffic"
}

resource "aws_security_group_rule" "vpc_public_allows_all_egress" {
  count             = var.create_vpc ? 1 : 0
  type              = local.outbound
  from_port         = local.all_ports
  to_port           = local.all_ports
  protocol          = local.all_protocols
  security_group_id = aws_security_group.vpc_public_sg[0].id
  cidr_blocks       = local.all_cidr_blocks
  description       = "Allow all egress traffic"
}