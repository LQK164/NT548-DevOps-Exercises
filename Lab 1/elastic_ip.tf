# Tạo Elastic IP cho NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "Nhom11-ENG"
  }
}