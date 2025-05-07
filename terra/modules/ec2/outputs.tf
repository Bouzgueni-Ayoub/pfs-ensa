output "public_ip" {
  value = aws_eip.wireguard_eip.public_ip
}
