variable "aws_region" { default = "eu-central-1" }
variable "client_public_key" {
  description = "WireGuard peer (client) public key to insert into server config"
  type        = string
  # NO default = prompt will happen
}
