resource "aws_s3_bucket" "wireguard_configs" {
  bucket = "wireguard-configs-${random_id.suffix.hex}"
  force_destroy = true  
  tags = {
    Name        = "WireGuard Configs"
    Environment = "Dev"
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}

# Required for setting bucket as ObjectWriter 
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

resource "aws_s3_bucket" "ansible_files" {
  bucket = "ansible-files-${random_id.suffix.hex}"
  force_destroy = true  
  tags = {
    Name        = "Ansible files"
    Environment = "Dev"
  }
}

# Required for setting bucket as ObjectWriter 
resource "aws_s3_bucket_ownership_controls" "ansible_files" {
  bucket = aws_s3_bucket.ansible_files.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Optional: Block all public access
resource "aws_s3_bucket_public_access_block" "ansible_files" {
  bucket = aws_s3_bucket.ansible_files.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
resource "aws_s3_object" "ansible_files" {

  for_each = {
    for file in fileset("${path.root}/modules/ec2/ansible", "**") :
    file => file
  }

  bucket = aws_s3_bucket.ansible_files.id
  key    = "ansible/${each.key}"                       # preserve subfolders
  source = "${path.root}/modules/ec2/ansible/${each.key}"
  etag   = filemd5("${path.root}/modules/ec2/ansible/${each.key}")
}
