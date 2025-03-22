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

# 3. Use ALB in Front of These Nginx Servers in VPC-Private
* Deploy an Internal Application Load Balancer (ALB) in VPC-Private across multiple private subnets.
* Configure a Target Group to register Nginx instances created by the Auto Scaling Group.
* Attach a Security Group that allows HTTP/HTTPS traffic from internal sources.
* Set Listener Rules to forward requests to the Nginx Target Group.

# 4. Create Bastion Host in VPC-Public
* Launch a Bastion Host (Jump Server) in a public subnet of VPC-Public.
* Assign a public or Elastic IP for external access.
* Configure a Security Group:
    * Allow SSH access only from trusted IPs (e.g., your local machine).
    * Allow SSH access to private instances in VPC-Private over the Transit Gateway.

# 5. Deploy NAT Gateway in VPC-Public for VPC-Private Instances to Access the Internet via Transit Gateway
* Create a NAT Gateway in VPC-Public in a public subnet.
* Attach an Elastic IP to the NAT Gateway.
* Update VPC-Private Route Tables:
    * Send all internet-bound traffic (0.0.0.0/0) to the NAT Gateway in VPC-Public via the Transit Gateway.
* Ensure private instances have a Security Group rule allowing outbound internet traffic via the NAT Gateway.
* This setup enables private Nginx instances to fetch updates and packages from the internet without exposing them directly.