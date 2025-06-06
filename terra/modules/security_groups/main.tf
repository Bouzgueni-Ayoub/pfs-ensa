resource "aws_security_group" "allow_wireguard_and_ssh" {
  name        = "allow_wireguard_and_ssh"
  description = "Allow WireGuard VPN and SSH access"
  vpc_id      = var.vpc_id
  # Ingress rules
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow access from any IP for the WireGuard VPN (can be more restrictive if needed)

  }

  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.200/32"]

  }

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  #After testing we will use our IP address

  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  #After testing we will use our IP address

  }

  ingress {
    from_port   = 51820
    to_port     = 51820
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow access from any IP for the WireGuard VPN (can be more restrictive if needed)
  }
  
ingress {
    from_port   = 9586
    to_port     = 9586
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Egress rule to allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Allow all ICMP IPv4"
    from_port        = -1
    to_port          = -1
    protocol         = "icmp"
    cidr_blocks      = ["0.0.0.0/0"]  # Allow from anywhere
  }

}

