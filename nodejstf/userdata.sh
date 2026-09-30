#!/bin/bash

set -e

# Update packages
apt-get update -y
apt-get upgrade -y

# Install required packages
apt-get install -y curl git

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
apt-get install -y nodejs

# Verify Node.js installation
node -v
npm -v

# Install PM2
npm install -g pm2

# Clone your application
cd /opt

git clone https://github.com/YOUR_USERNAME/YOUR_REPOSITORY.git nodejs-app
#the link of github repo need to be added here


cd /opt/nodejs-app

# Install application dependencies
npm install

# Start application using PM2
pm2 start npm --name "nodejs-app" -- start

# Configure PM2 to start after reboot
pm2 startup systemd -u root --hp /root

pm2 save

echo "Node.js application deployment completed"
