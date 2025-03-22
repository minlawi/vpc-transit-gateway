resource "aws_security_group" "vpc_private_sg" {
  count  = var.create_vpc ? 1 : 0
  vpc_id = aws_vpc.vpc_private[0].id
  name   = "vpc-private-sg"
  tags = {
    Name = "vpc-private-sg"
  }
}

resource "aws_security_group_rule" "vpc_private_allows_http_ingress_from_alb" {
  count                    = var.create_vpc ? 1 : 0
  type                     = local.inbound
  from_port                = local.http_port
  to_port                  = local.http_port
  protocol                 = local.http_protocol
  security_group_id        = aws_security_group.vpc_private_sg[0].id
  source_security_group_id = aws_security_group.vpc_private_alb_sg[0].id
  description              = "Allow HTTP traffic from ALB"
}

resource "aws_security_group_rule" "vpc_private_allows_all_egress" {
  count             = var.create_vpc ? 1 : 0
  type              = local.outbound
  from_port         = local.all_ports
  to_port           = local.all_ports
  protocol          = local.all_protocols
  security_group_id = aws_security_group.vpc_private_sg[0].id
  cidr_blocks       = [local.all_cidr_blocks]
  description       = "Allow all egress traffic"
}