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
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.vpc_public_sg[0].id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all ingress traffic"
}

resource "aws_security_group_rule" "vpc_public_allows_all_egress" {
  count             = var.create_vpc ? 1 : 0
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.vpc_public_sg[0].id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all egress traffic"
}