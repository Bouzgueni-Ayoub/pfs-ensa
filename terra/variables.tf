variable "aws_region" { default = "eu-central-1" }

variable "wireguard_clients" {
  description = "List of WireGuard clients to generate configs for"
  type = list(object({
    name               = string
    client_private_key = string
    client_ip          = string
  }))
}