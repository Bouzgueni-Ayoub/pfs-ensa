variable "subnet_id" {
  type = string
}

variable "security_group_id" {
  type = string
}
variable "wireguard_profile" {
  type = string
}
variable "ansible_profile" {
  type = string
}
variable "wireguard_clients" {
  description = "List of WireGuard clients to generate configs for"
  type = list(object({
    name               = string
    client_private_key = string
    client_public_key = string
    client_ip          = string
  }))
}
variable "wireguard_configs" {
  type = string
}