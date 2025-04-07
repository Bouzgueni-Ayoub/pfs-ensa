# Creating the main VPC
resource "aws_vpc" "Main-VPC" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "Main-VPC"
  }

}
# Creating the main Subnet in the VPC
resource "aws_subnet" "Main-Subnet" {
  vpc_id     = aws_vpc.Main-VPC.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Main-Subnet"
  }
}
# Creating the routing table
resource "aws_route_table" "Main-VPC-Route-Table" {
  vpc_id = aws_vpc.example.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example.id
  }

  tags = {
    Name = "Main-VPC-Route-Table"
  }
}