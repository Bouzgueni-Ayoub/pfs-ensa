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

resource "aws_instance" "wiregueard_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name = "main-key"
  subnet_id = aws_subnet.Main_Subnet.id
  vpc_security_group_ids = [security_groups.allow_wireguard_and_ssh.id]

  tags = {
    Name = "ec2 instance "
  }
}