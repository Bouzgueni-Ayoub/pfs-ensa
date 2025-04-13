output "wireguard_configs_arn" {
  value = aws_s3_bucket.wireguard_configs.arn
}
output "ansible_files" {
  value = aws_s3_bucket.ansible_files.arn
}
