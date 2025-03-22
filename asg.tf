resource "aws_launch_template" "vpc_private_nginx_lt" {
  count                  = var.create_vpc ? 1 : 0
  name_prefix            = "nginx-lt"
  image_id               = data.aws_ami.ubuntu.id
  instance_type          = local.t2_micro
  key_name               = "my-key-pair"
  user_data              = filebase64("${path.module}/scripts/nginx-install.sh")
  vpc_security_group_ids = [aws_security_group.vpc_private_sg[0].id]
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "nginx-instance-${count.index}"
    }
  }
}

resource "aws_autoscaling_group" "vpc_private_nginx_asg" {
  count            = var.create_vpc ? 1 : 0
  depends_on       = [aws_ec2_transit_gateway_route_table_association.tgw_route_table_association_private_vpc, aws_ec2_transit_gateway_route_table_association.tgw_route_table_association_public_vpc]
  desired_capacity = 2
  max_size         = 4
  min_size         = 1
  launch_template {
    id      = aws_launch_template.vpc_private_nginx_lt[0].id
    version = "$Latest"
  }
  vpc_zone_identifier       = aws_subnet.subnet_private[*].id
  target_group_arns         = [aws_lb_target_group.vpc_private_nginx_tg[0].arn]
  health_check_type         = "ELB"
  health_check_grace_period = 120
  force_delete              = true
  tag {
    key                 = "Name"
    value               = "nginx-instance-${count.index}"
    propagate_at_launch = true
  }
}