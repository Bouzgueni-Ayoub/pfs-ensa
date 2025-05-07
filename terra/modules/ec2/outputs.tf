output "public_ip" {
  value = aws_eip.wireguard_eip.public_ip
}
output "ansible_vars" {
  value = local_file.ansible_vars.filename
}
output "ansible_controller" {
  value= aws_instance.ansible_controller.id
}
