output "vpc_public_bastion_ip" {
  value = var.create_vpc ? aws_instance.vpc_public_bastion[0].public_ip : null

}

output "alb_dns_name" {
  value = var.create_vpc ? aws_lb.vpc_private_alb[0].dns_name : null

}