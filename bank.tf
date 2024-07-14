#Initialize Terraform
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS provider
provider "aws" {
  region = "ap-south-1"
}


# Create VPC

resource "aws_vpc" "myvpc9" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "myvpc9"
  }
}

# Create Subnet in ap-south-1b

resource "aws_subnet" "mysubnet9_b" {
  vpc_id            = aws_vpc.myvpc9.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "mysubnet9_b"
  }
}

# Internet Gateway

resource "aws_internet_gateway" "mygw9" {
  vpc_id = aws_vpc.myvpc9.id

  tags = {
    Name = "mygw9"
  }
}

# Route Table

resource "aws_route_table" "myrt9" {
  vpc_id = aws_vpc.myvpc9.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mygw9.id
  }

  tags = {
    Name = "myrt9"
  }
}

# Route Table Association

resource "aws_route_table_association" "myrta9" {
  subnet_id      = aws_subnet.mysubnet9_b.id
  route_table_id = aws_route_table.myrt9.id
}

# Security Groups

resource "aws_security_group" "mysg9" {
  name        = "mysg9"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.myvpc9.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "mysg9"
  }
}

# Create Instance with Elastic IP Allocation

resource "aws_instance" "instance9" {
  ami                    = "ami-0f58b397bc5c1f2e8"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.mysubnet9_b.id
  vpc_security_group_ids = [aws_security_group.mysg9.id]
  key_name               = "pihukey"
  associate_public_ip_address = true
  availability_zone      = "ap-south-1b"  # Specify the availability zone

  tags = {
    Name = "Prod_server"
  }
}

# Allocate Elastic IP

resource "aws_eip" "instance_eip" {
  instance   = aws_instance.instance9.id
  vpc        = true
  depends_on = [aws_instance.instance9]  # Ensure instance is created first
}

