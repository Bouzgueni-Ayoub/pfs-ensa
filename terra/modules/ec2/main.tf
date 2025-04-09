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

# Create the ENI
resource "aws_network_interface" "eni" {
  subnet_id       = var.subnet_id
  security_groups = [var.security_group_id]
}

# Create and associate EIP to ENI
resource "aws_eip" "eip" {
  domain             = "vpc"
  network_interface  = aws_network_interface.eni.id
}

# Launch the EC2 instance and attach the ENI as its primary network interface
resource "aws_instance" "wireguard_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = "main-key"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.eni.id
  }

  tags = {
    Name = "wireguard-server"
  }
}
data "aws_subnet" "selected" {
  id = var.subnet_id
}
resource "aws_ebs_volume" "wireguard_data" {
  availability_zone = data.aws_subnet.selected.availability_zone
  size              = 1
  type              = "gp2"
  tags = {
    Name = "wireguard-config"
  }
}
