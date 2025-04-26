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

# Launch the EC2 instance normally (no manual ENI)
resource "aws_instance" "wireguard_server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  key_name                    = "main-key"
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true
  iam_instance_profile        = var.wireguard_profile
  user_data                   = file("${path.module}/cloud-init.sh")
  private_ip = "10.0.1.100"
  vpc_security_group_ids = [var.security_group_id]

  tags = {
    Name = "wireguard-server"
  }
}

# Allocate and associate an EIP to the instance
resource "aws_eip" "wireguard_eip" {
  instance = aws_instance.wireguard_server.id
  domain   = "vpc"
}

