# Creating the main VPC
resource "aws_vpc" "Main_VPC" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "Main-VPC"
  }
}

# Creating the main Subnet in the VPC
resource "aws_subnet" "Main_Subnet" {
  vpc_id     = aws_vpc.Main_VPC.id
  cidr_block = "10.0.1.0/24"
  
  # Optional: specify availability_zone for more control
  # availability_zone = "us-east-1a"

  tags = {
    Name = "Main-Subnet"
  }
}

# Creating the Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.Main_VPC.id

  tags = {
    Name = "Main-VPC-Gateway"
  }
}

# Creating the Routing Table
resource "aws_route_table" "Main_VPC_Route_Table" {
  vpc_id = aws_vpc.Main_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Main-VPC-Route-Table"
  }
}

# Associating the Route Table with the Subnet
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.Main_Subnet.id
  route_table_id = aws_route_table.Main_VPC_Route_Table.id
}
