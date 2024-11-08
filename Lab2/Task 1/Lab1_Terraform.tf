terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.6"
    }
  }
  required_version = ">= 0.13"
}

variable "aws_access_key_id" {
  description = "The AWS access key ID"
  type        = string
}

variable "aws_secret_access_key" {
  description = "The AWS secret access key"
  type        = string
}

provider "aws" {
  region = "us-east-1"
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}

# Tạo VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Nhom11-VPC"
  }
}

# Tạo Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Nhom11-PubSub"
  }
}

# Tạo Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Nhom11-PriSub"
  }
}

# Tạo Internet Gateway cho Public Subnet
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "Nhom11-IGW"
  }
}

# Tạo Elastic IP cho NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "Nhom11-ENG"
  }
}

# Tạo NAT Gateway cho Private Subnet
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "Nhom11-NGW"
  }
}

# Tạo Public Route Table và định tuyến qua Internet Gateway
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id

  }

  tags = {
    Name = "Nhom11-PubRT"
  }
}

# Tạo Private Route Table và định tuyến qua NAT Gateway
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "Nhom11-PriRT"
  }
}

# Gán Public Subnet vào Public Route Table
resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Gán Private Subnet vào Private Route Table
resource "aws_route_table_association" "private_rt_assoc" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}

# Tạo EC2 instance trong Public Subnet
resource "aws_instance" "public_ec2" {
  ami             = "ami-0866a3c8686eaeeba"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.public_sg.id]

  tags = {
    Name = "Nhom11-PubEC2"
  }
}

# Tạo EC2 instance trong Private Subnet
resource "aws_instance" "private_ec2" {
  ami             = "ami-0866a3c8686eaeeba"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.private_subnet.id
  security_groups = [aws_security_group.private_sg.id]

  tags = {
    Name = "Nhom11-PriEC2"
  }
}

# Tạo Security Group cho Public EC2
resource "aws_security_group" "public_sg" {
  vpc_id = aws_vpc.my_vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["123.250.165.100/32"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Nhom11-PubSecGR"
  }
}

# Tạo Security Group cho Private EC2
resource "aws_security_group" "private_sg" {
  vpc_id = aws_vpc.my_vpc.id
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.public_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Nhom11-PriSecGR"
  }
}