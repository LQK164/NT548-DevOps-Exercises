# Tạo Internet Gateway cho Public Subnet
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "Nhom11-IGW"
  }
}