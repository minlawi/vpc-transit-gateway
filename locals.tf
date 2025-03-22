locals {
  all_cidr_blocks = "0.0.0.0/0"
  disable         = "disable"
  t2_micro        = "t2.micro"
  inbound         = "ingress"
  outbound        = "egress"
  all_ports       = -1
  all_protocols   = "-1"
  http_port       = 80
  http_protocol   = "tcp"
}