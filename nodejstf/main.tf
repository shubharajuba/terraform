terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# -----------------------------
# VPC
# -----------------------------

resource "aws_vpc" "nodejs_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "nodejs-poc-vpc"
  }
}

# -----------------------------
# Public Subnet
# -----------------------------

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.nodejs_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "nodejs-poc-public-subnet"
  }
}

# -----------------------------
# Internet Gateway
# -----------------------------

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.nodejs_vpc.id

  tags = {
    Name = "nodejs-poc-igw"
  }
}

# -----------------------------
# Route Table
# -----------------------------

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.nodejs_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "nodejs-poc-public-rt"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# -----------------------------
# Security Group
# -----------------------------

resource "aws_security_group" "nodejs_sg" {
  name        = "nodejs-poc-sg"
  description = "Security group for Node.js POC"
  vpc_id      = aws_vpc.nodejs_vpc.id

  # SSH
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  # Node.js application
  ingress {
    description = "Node.js application"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound
  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nodejs-poc-sg"
  }
}

# -----------------------------
# EC2 Instance
# -----------------------------

resource "aws_instance" "nodejs_server" {
  ami           = var.ami_id
  instance_type = "t3.micro"

  subnet_id = aws_subnet.public_subnet.id

  key_name = var.key_name

  vpc_security_group_ids = [
    aws_security_group.nodejs_sg.id
  ]

  # AWS automatically assigns a public IPv4 address.
  # No Elastic IP is created.
  associate_public_ip_address = true

  user_data = file("${path.module}/userdata.sh")

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name        = "nodejs-poc"
    Environment = "POC"
    Application = "NodeJS"
  }
}