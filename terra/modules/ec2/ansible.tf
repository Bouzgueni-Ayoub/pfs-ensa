# Creating ENI for Ansible
resource "aws_network_interface" "eni_ansible" {
  subnet_id       = var.subnet_id
  security_groups = [var.security_group_id]
}

# EIP for Ansible EC2
resource "aws_eip" "eip_ansible" {
  domain            = "vpc"
  network_interface = aws_network_interface.eni_ansible.id
}

# Ansible EC2 instance
resource "aws_instance" "ansible_controller" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = "main-key"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.eni_ansible.id
  }

  iam_instance_profile = var.ansible_profile
  # Install Ansible with user_data
  user_data = file("${path.module}/ansible-userdata.sh")

  tags = {
    Name = "ansible-controller"
  }
}

resource "local_file" "ansible_vars" {
   filename = "${path.module}/ansible/var.yml"
  content  = yamlencode({
    client_public_key = var.client_public_key 
    server_public_ip= aws_eip.wireguard_eip
  })
}
