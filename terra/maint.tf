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

module "vpc" {
  source = "./modules/vpc"
  # other inputs if any
}

module "security_groups" {
  source = "./modules/security_groups"
  # other inputs if any
}

module "ec2" {
  source            = "./modules/ec2"
  subnet_id         = module.vpc.subnet_id
  security_group_id = module.security_groups.allow_wireguard_and_ssh_id
}
