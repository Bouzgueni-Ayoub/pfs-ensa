terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
} 
# Creating a vpc
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name  = "Production"
  }
}
# Creating a subnet for the vpc
resource "aws_subnet" "main-vpc-subnet" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "prod-subnet"
  }
}
# Creating an internet gateway

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-gateway"
  }
}

# Creating a route table

resource "aws_route_table" "route-table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "10.0.1.0/24"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "example"
  }
}

# Creating association between the route table and the subnet

resource "aws_route_table_association" "association" {
  subnet_id      = aws_subnet.main-vpc-subnet.id
  route_table_id = aws_route_table.route-table.id
}

# Creating a security for the subnet 
resource "aws_security_group" "main-security-group" {
  name        = "main-security-group"
  description = "Allow SSH, HTTP, and HTTPS from/to the internet"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "main-security-group"
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Creating a network interface 

resource "aws_network_interface" "network-interface" {
  subnet_id       = aws_subnet.main-vpc-subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.main-security-group.id]
 
}

# Creating an elastic ip adress 

resource "aws_eip" "eip" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.network-interface.id
  associate_with_private_ip = "10.0.1.50"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install apache2 -y
              sudo systemctl enable apache2
              sudo systemctl start apache2
              EOF
  tags = {
    Name = "HelloWorld"
  }
  network_interface {
    network_interface_id = aws_network_interface.network-interface.id
    device_index         = 0
  }
}
output "instance_public_ip" {
  value = aws_instance.web.public_ip
}