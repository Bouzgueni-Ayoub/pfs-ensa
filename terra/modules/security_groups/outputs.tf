output "security_group_id" {
  description = "The ID of the security group"
  value       = aws_security_group.allow_wireguard_and_ssh.id
}

output "security_group_name" {
  description = "The name of the security group"
  value       = aws_security_group.allow_wireguard_and_ssh.name
}

output "security_group_ssh_rule" {
  description = "Ingress rule for SSH (port 22)"
  value = [for rule in aws_security_group.allow_wireguard_and_ssh.ingress : rule.cidr_blocks]
}

output "security_group_wireguard_rule" {
  description = "Ingress rule for WireGuard (UDP port 51820)"
  value = [for rule in aws_security_group.allow_wireguard_and_ssh.ingress : rule.cidr_blocks]
}
