output "wireguard_profile" {
  value = aws_iam_instance_profile.wireguard_profile.name
}
output "ansible_profile" {
  value = aws_iam_instance_profile.ansible_profile.name
}