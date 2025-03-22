# 1. Two VPC Peering with Transit Gateway
* Create two VPCs:
* VPC-Public (for external-facing resources, including the Bastion Host and NAT Gateway).
* VPC-Private (for internal resources, including Nginx instances behind an ALB).
* Ensure non-overlapping CIDR ranges for both VPCs.
* Deploy an AWS Transit Gateway (TGW) to facilitate communication between the two VPCs.
* Attach both VPCs to the Transit Gateway using Transit Gateway Attachments.
* Update Route Tables in each VPC:
* VPC-Public routes VPC-Private traffic to the Transit Gateway.
* VPC-Private routes VPC-Public traffic to the Transit Gateway.
* VPC-Private routes internet-bound traffic to the NAT Gateway in VPC-Public.