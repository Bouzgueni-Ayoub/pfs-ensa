output "wireguard_instance_ip" {
  value = module.ec2.aws_eip.eip.public_ip
}