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
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.vpc_private_sg[0].id
  source_security_group_id = aws_security_group.vpc_private_alb_sg[0].id
  description              = "Allow HTTP traffic from ALB"
}

resource "aws_security_group_rule" "vpc_private_allows_all_egress" {
  count             = var.create_vpc ? 1 : 0
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.vpc_private_sg[0].id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all egress traffic"
}