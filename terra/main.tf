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
  vpc_id  = module.vpc.vpc_id
  # other inputs if any
}

module "ec2" {
  source            = "./modules/ec2"
  subnet_id         = module.vpc.subnet_id
  security_group_id = module.security_groups.allow_wireguard_and_ssh_id
  wireguard_profile = module.iam.wireguard_profile
  ansible_profile   = module.iam.ansible_profile
  wireguard_clients = var.wireguard_clients
  wireguard_configs = module.s3.wireguard_configs
  }
module "s3" {
  source = "./modules/s3"
  ansible_controller= module.ec2.ansible_controller
  ansible_vars = module.ec2.ansible_vars
  
}
module "iam" {
  source = "./modules/iam"
  s3_bucket_arn_wireguard = module.s3.wireguard_configs_arn
  s3_bucket_arn_ansible_files = module.s3.ansible_files
}

