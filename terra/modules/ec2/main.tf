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
  private_ips     = ["10.0.1.100"]
  source_dest_check = false
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
  iam_instance_profile    = var.wireguard_profile
  user_data = file("${path.module}/cloud-init.sh")
  
  tags = {
    Name = "wireguard-server"
  }
}
