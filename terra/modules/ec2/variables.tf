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
variable "client_public_key" {
  description = "WireGuard peer (client) public key to insert into server config"
  type        = string
  # NO default = prompt will happen
}
