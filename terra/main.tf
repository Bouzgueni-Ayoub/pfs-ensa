terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
#resource "aws_s3_bucket" "my-bucket"{
 #   tags = {
  #  Name        = "My bucket"
   # Environment = "Dev"
  #}
#}

/*resource "aws_instance" "first-server" {
  ami = "ami-0ecf75a98fe8519d7"
  instance_type = "t2.micro"
  tags = {
    Name="first ec2 instance"
  }
  
}*/ 
#create vpc
resource "aws_vpc" "vpc-test" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name="exercice-vpc"
  }
}
#create internal Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc-test.id
  tags = {
    Name = "yahia-gw"
  }
}

#create custom Route Table 

resource "aws_route_table" "yahia-route-table" {
  vpc_id = aws_vpc.vpc-test.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "yahia route table"
  }
}

#create a subnet 

resource "aws_subnet" "test-subnet" {
  vpc_id = aws_vpc.vpc-test.id
  cidr_block = "10.0.1.0/24"

  
  tags = {
    Name="yahia-subnet"
  }
}
#associate subnet with route table 
resource "aws_route_table_association" "a-yahia" {
  subnet_id      = aws_subnet.test-subnet.id
  route_table_id = aws_route_table.yahia-route-table.id
}

#create security groupe to allow port 22,80,443

resource "aws_security_group" "allow_web" {
  name        = "allow_web_trrafic"
  description = "Allow web inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.vpc-test.id

  # Inbound rules to allow ports 22, 80, 443
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allows SSH from anywhere (adjust if needed)
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allows HTTP from anywhere (adjust if needed)
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allows HTTPS from anywhere (adjust if needed)
  }

  # Outbound rule to allow all traffic (default)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # -1 means all protocols
    cidr_blocks = ["0.0.0.0/0"]  # Allows all outbound traffic
  }

  tags = {
    Name = "allow_web_yahia"
  }
}

#create a network interface with an ip in the subnet that was created in step 4 

resource "aws_network_interface" "web_server_yahia" {
  subnet_id       = aws_subnet.test-subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]


}
#assign an elastic ip to the network interface created in step 7

resource "aws_eip" "one" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.web_server_yahia.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [ aws_internet_gateway.gw ]
}
#create ubuntu server and install apache2

resource "aws_instance" "web_server_instance" {
  ami = "ami-03250b0e01c28d196"
  instance_type = "t2.micro"
  key_name = "first-key"

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.web_server_yahia.id
  }

  user_data = <<-EOF
          #1/bin/bash
          sudo apt update -y
          sudo apt install apache2 -y
          sudo systemctl start apache2
          sudo bash -c 'echo your very first web server >/var/www/html/index.html'
          EOF
   tags = {
    Name = "webserver-yahia"
  }
}