#!/bin/bash
# Log all output to a file for debugging
exec > /var/log/user-data.log 2>&1
set -x  # Enable debugging

# Wait for network to be available
until ping -c 1 8.8.8.8; do
echo "Waiting for network..."
sleep 10
done

# Update package list and install NGINX
apt-get update -y
apt-get install -y nginx

# Start and enable NGINX
systemctl start nginx
systemctl enable nginx


# Get the auto-assign private IP address
SERVER_IP=$(hostname -I | awk '{print $1}')

# Create a custom index page
echo "<h1>Welcome to Nginx! Running on $SERVER_IP</h1>" > /var/www/html/index.html

# Verify NGINX is running
systemctl status nginx
