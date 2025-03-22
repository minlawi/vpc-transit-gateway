resource "aws_security_group" "vpc_private_alb_sg" {
  count  = var.create_vpc ? 1 : 0
  vpc_id = aws_vpc.vpc_private[0].id
  name   = "internal-alb-sg"
  tags = {
    Name = "internal-alb-sg"
  }
}

resource "aws_security_group_rule" "vpc_private_alb_sg_allow_http_ingress_private_subnets" {
  count             = var.create_vpc ? 1 : 0
  type              = local.inbound
  from_port         = local.http_port
  to_port           = local.http_port
  protocol          = local.http_protocol
  security_group_id = aws_security_group.vpc_private_alb_sg[0].id
  cidr_blocks       = [for subnet in aws_subnet.subnet_private : subnet.cidr_block]
  description       = "Allow HTTP traffic from Private Subnets"

}

resource "aws_security_group_rule" "vpc_private_alb_sg_allow_http_from_vpc_public" {
  count             = var.create_vpc ? 1 : 0
  type              = local.inbound
  from_port         = local.http_port
  to_port           = local.http_port
  protocol          = local.http_protocol
  cidr_blocks       = [aws_vpc.vpc_public[0].cidr_block]
  security_group_id = aws_security_group.vpc_private_alb_sg[0].id
  description       = "Allow HTTP traffic from VPC Public"

}

resource "aws_security_group_rule" "vpc_private_alb_sg_allow_all_egress" {
  count             = var.create_vpc ? 1 : 0
  type              = local.outbound
  from_port         = local.all_ports
  to_port           = local.all_ports
  protocol          = local.all_protocols
  security_group_id = aws_security_group.vpc_private_alb_sg[0].id
  cidr_blocks       = [local.all_cidr_blocks]
  description       = "Allow all egress traffic"
}