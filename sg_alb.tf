resource "aws_security_group" "vpc_private_alb_sg" {
  count  = var.create_vpc ? 1 : 0
  vpc_id = aws_vpc.vpc_private[0].id
  name   = "internal-alb-sg"
  tags = {
    Name = "internal-alb-sg"
  }
}

resource "aws_security_group_rule" "vpc_private_alb_sg_allow_http_ingress" {
  count             = var.create_vpc ? 1 : 0
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.vpc_private_alb_sg[0].id
  cidr_blocks       = [aws_vpc.vpc_public[0].cidr_block]
  description       = "Allow HTTP from public_vpc CIDR blocks"

}

resource "aws_security_group_rule" "vpc_private_alb_sg_allow_all_egress" {
  count             = var.create_vpc ? 1 : 0
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.vpc_private_alb_sg[0].id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all egress traffic"
}