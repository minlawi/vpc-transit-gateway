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

# 2. Use Auto Scaling to Create Nginx Instances in VPC-Private
* Define a Launch Template with:
    * Amazon Linux or Ubuntu AMI.
    * Nginx installation script in the user data (yum install -y nginx or apt install -y nginx).
    * Security Group that allows inbound HTTP/HTTPS from the ALB and outbound access via the NAT Gateway.
* Create an Auto Scaling Group (ASG) in VPC-Private with instances in private subnets.
* Set desired, minimum, and maximum capacity based on traffic needs.
* Enable Auto Scaling policies to adjust instance count dynamically.
* Ensure instances have no public IPs, requiring access via Bastion Host or ALB.