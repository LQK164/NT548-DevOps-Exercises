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
  ami             = var.AMIS[var.REGION]
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.public_sg.id]

  tags = {
    Name = "Nhom11-PubEC2"
  }
}

# Tạo EC2 instance trong Private Subnet
resource "aws_instance" "private_ec2" {
  ami             = var.AMIS[var.REGION]
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

output "public_instance_public_ip" {
  value = aws_instance.public_ec2.public_ip
}

output "public_instance_private_ip" {
  value = aws_instance.public_ec2.private_ip
}

output "private_instance_public_ip" {
  value = aws_instance.private_ec2.public_ip
}

output "private_instance_private_ip" {
  value = aws_instance.private_ec2.private_ip
}