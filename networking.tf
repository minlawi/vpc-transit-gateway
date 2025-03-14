resource "aws_vpc" "vpc" {
  count                = var.create_vpc ? length(var.cidr_block) : 0
  cidr_block           = var.cidr_block[count.index]
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "vpc-${count.index}"
  }
}
