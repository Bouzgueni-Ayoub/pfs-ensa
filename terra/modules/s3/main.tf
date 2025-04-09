resource "aws_s3_bucket" "wireguard_configs" {
  bucket = "wireguard-configs-${random_id.suffix.hex}"
  force_destroy = true  # Only if you want auto-delete for testing/dev
  tags = {
    Name        = "WireGuard Configs"
    Environment = "Dev"
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}

# Required for setting bucket as ObjectWriter (recommended if you don't want ACLs)
resource "aws_s3_bucket_ownership_controls" "wireguard_configs" {
  bucket = aws_s3_bucket.wireguard_configs.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Optional: Block all public access
resource "aws_s3_bucket_public_access_block" "wireguard_configs" {
  bucket = aws_s3_bucket.wireguard_configs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
