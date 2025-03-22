resource "aws_instance" "vpc_public_bastion" {
  count           = var.create_vpc ? 1 : 0
  ami             = data.aws_ami.ubuntu.id
  instance_type   = local.t2_micro
  key_name        = "my-key-pair"
  subnet_id       = aws_subnet.subnet_public[0].id
  security_groups = [aws_security_group.vpc_public_sg[0].id]
  tags = {
    Name = "bastion-host"
  }
  lifecycle {
    ignore_changes = [security_groups]
  }

}