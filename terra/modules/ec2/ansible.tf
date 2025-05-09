
# EIP for Ansible EC2
resource "aws_eip" "eip_ansible" {
  domain            = "vpc"
  instance = aws_instance.ansible_controller.id
}

# Ansible EC2 instance
resource "aws_instance" "ansible_controller" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = "main-key"
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true
  iam_instance_profile        = var.ansible_profile
  private_ip = "10.0.1.200"
  vpc_security_group_ids = [var.security_group_id]

  # Install Ansible with user_data
  user_data = file("${path.module}/ansible-userdata.sh")

  tags = {
    Name = "ansible-controller"
  }
}

resource "local_file" "ansible_vars" {
  filename = "${path.module}/ansible/var.yml"
  content  = yamlencode({
    server_endpoint   = aws_eip.wireguard_eip.public_ip
    wireguard_clients = var.wireguard_clients
    ansible_bucket_name = var.wireguard_configs
  })

}


