terraform {
  required_version = ">= 0.13.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }
  }
}

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

# Create Subnet
resource "aws_subnet" "mysubnet9" {
  vpc_id     = aws_vpc.myvpc9.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "mysubnet9"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "mygw9" {
  vpc_id = aws_vpc.myvpc9.id

  tags = {
    Name = "mygw9"
  }
}

# Create Route Table
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

# Associate Route Table with Subnet
resource "aws_route_table_association" "myrta9" {
  subnet_id      = aws_subnet.mysubnet9.id
  route_table_id = aws_route_table.myrt9.id
}

# Create Security Group
resource "aws_security_group" "mysg9" {
  name        = "mysg9"
  description = "Allow inbound HTTP and SSH traffic"
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
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "mysg9"
  }
}

# Create Instance
resource "aws_instance" "instance9" {
  ami                         = "ami-0c2af51e265bd5e0e"  # Update with your preferred AMI ID
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.mysubnet9.id
  vpc_security_group_ids      = [aws_security_group.mysg9.id]
  key_name                    = "pihukey"  # Update with your key pair name

  tags = {
    Name = "Prod Server"
  }
}

# Allocate Elastic IP
resource "aws_eip" "eip9" {
  vpc = true

  tags = {
    Name = "myeip9"
  }
}

# Associate Elastic IP with Instance
resource "aws_eip_association" "eip_assoc9" {
  instance_id   = aws_instance.instance9.id
  allocation_id = aws_eip.eip9.id
}

