terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
resource "aws_s3_bucket" "my-bucket"{
    tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}