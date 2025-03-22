resource "aws_lb" "vpc_private_alb" {
  count              = var.create_vpc ? 1 : 0
  name               = "vpc-private-internal-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.vpc_private_alb_sg[0].id]
  subnets            = aws_subnet.subnet_private[*].id
  tags = {
    Name = "internal-alb-${count.index}"
  }
}

resource "aws_lb_target_group" "vpc_private_nginx_tg" {
  count    = var.create_vpc ? 1 : 0
  name     = "nginx-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc_private[0].id
  tags = {
    Name = "nginx-tg-${count.index}"
  }
  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = "80"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 10
  }
}

resource "aws_lb_listener" "vpc_private_nginx_listener" {
  count             = var.create_vpc ? 1 : 0
  load_balancer_arn = aws_lb.vpc_private_alb[0].arn
  port              = local.http_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.vpc_private_nginx_tg[0].arn
  }
}