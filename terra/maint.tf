terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}
# VPC Module
module "vpc" {
  source = "./modules/vpc"
  # Pass variables from the root to the module

}

# Security Group Module
module "security_groups" {
  source = "./modules/security_groups"

}

# EC2 Module
module "ec2" {
  source = "./modules/ec2"
  
}