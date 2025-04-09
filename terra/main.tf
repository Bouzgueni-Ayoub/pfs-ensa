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
  iam_instance_profile = module.iam.iam_instance_profile
}
module "s3" {
  source = "./modules/s3"
}
module "iam" {
  source = "./modules/iam"
  s3_bucket_arn = module.s3.wireguard_configs_arn
}