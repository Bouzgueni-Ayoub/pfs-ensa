terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
resource "aws_vpc" "adil-vpc" {
  cidr_block = "10.0.0.0/16"
  tags={
    Name="adil-VPC"
  }
}
resource "aws_internet_gateway" "adil-VPC-gateway" {
  vpc_id = aws_vpc.adil-vpc.id

  tags = {
    Name = "adil-VPC-gw"
  }
}
resource "aws_route_table" "adil-VPC-route" {
  vpc_id = aws_vpc.adil-vpc.id

  route {
    cidr_block = "0.0.0.0/24"
    gateway_id = aws_internet_gateway.adil-VPC-gateway.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.adil-VPC-gateway.id
  }

  tags = {
    Name = "adil-VPC-route"
  }
}
resource "aws_subnet" "adil-VPC-subnet" {
  vpc_id     = aws_vpc.adil-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "adil-VPC-route"
  }
}
resource "aws_route_table_association" "assoc-subnet-route" {
    subnet_id = aws_subnet.adil-VPC-subnet.id
    route_table_id = aws_route_table.adil-VPC-route.id

}
resource "aws_security_group" "sec-grp-VPC" {
  vpc_id = aws_vpc.adil-vpc.id
  name = "sec-grp"
  description = "Traffic to web"

  ingress {
    description = "HTTPS"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "sec-grp-VPC"
  }
}
resource "aws_network_interface" "net-interface" {
  subnet_id       = aws_subnet.adil-VPC-subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.sec-grp-VPC.id]
}
resource "aws_eip" "elastic-" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.net-interface.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [aws_internet_gateway.adil-VPC-gateway]
}
resource "aws_instance" "adil-server" {
    ami = "ami-0ecf75a98fe8519d7"
    instance_type = "t2.micro"
    #key_name = "terraform-test"
    network_interface {
      device_index = 0
      network_interface_id = aws_network_interface.net-interface.id
    }
    user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt install apache2 -y
                sudo systemctl start apache2
                sudo bash -c 'echo welcome to Ubuntu server made by Adil > var/www/html/index.html' 
                EOF
            tags = {
                Name = "Web-Server"
            }
}