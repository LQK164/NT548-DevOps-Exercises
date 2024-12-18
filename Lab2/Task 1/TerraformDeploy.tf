terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.6"
    }
  }
  required_version = ">= 0.13"
}

provider "aws" {
  region = "us-east-1"
}

# Tạo VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Nhom11-VPC"
  }
}

resource "aws_kms_key" "example" {
  description = "Example KMS key for CloudWatch Logs"
  enable_key_rotation    = true
  is_enabled = true
  policy      = <<POLICY
  {
    "Version": "2012-10-17",
    "Id": "key-consolepolicy-3",
    "Statement": [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::211125766710:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
        {
            "Sid": "Allow access for Key Administrators",
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "arn:aws:iam::211125766710:role/admin",
                    "arn:aws:iam::211125766710:user/cloud_user"
                ]
            },
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:DescribeKey",
                "kms:GenerateDataKey"
            ],
            "Resource": "arn:aws:kms:us-east-1:211125766710:key/d9cd4955-8b8b-4f9e-b51b-ca85a5eb12f9"
        }
    ]
  }
POLICY
}
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name = "VPCFlowLogs"
  kms_key_id = aws_kms_key.example.arn
  retention_in_days = 365  #Keep logs in 1 year
}

resource "aws_flow_log" "flow_log" {
  #iam_role_arn = ""
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs.arn
  traffic_type = "ALL"
  vpc_id = aws_vpc.my_vpc.id

  depends_on = [aws_cloudwatch_log_group.vpc_flow_logs]
}

#Security Group for VPC
resource "aws_default_security_group" "vpc_security_group" {
  vpc_id = aws_vpc.my_vpc.id
#  ingress {
#    protocol = "-1"
#    from_port = 0
#    to_port = 0
#    self = true
#  }
#  egress {
#   protocol = "-1"
#    from_port = 0
#    to_port = 0
#    cidr_blocks = [ "0.0.0.0/0" ]
#  }
}


# Tạo Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  #map_public_ip_on_launch = true

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
  monitoring = true
  ebs_optimized = true
  iam_instance_profile = "EMR_EC2_DefaultRole"
  root_block_device {
    encrypted     = true
  }
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
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
  monitoring = true
  ebs_optimized = true
  iam_instance_profile = "EMR_EC2_DefaultRole"
  root_block_device {
    encrypted     = true
  }
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
  tags = {
    Name = "Nhom11-PriEC2"
  }
}

# Tạo Security Group cho Public EC2
resource "aws_security_group" "public_sg" {
  vpc_id = aws_vpc.my_vpc.id
  description = "Security Group for Public EC2"
  ingress {
    description = "Block an IP random"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["123.250.165.100/32"]
  }
  egress {
    description = " "
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
  description = "Security Group for Private EC2"
  ingress {
    description = "Using SSH to access the Internet"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.public_sg.id]
  }
  egress {
    description = " "
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Nhom11-PriSecGR"
  }
}