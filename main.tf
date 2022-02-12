terraform {
  required_providers {
    aws = {
      version = "~> 3.0"
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}


module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "3.12.0"
  name = "prod-vpc"
  cidr = "192.168.0.0/23"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["192.168.0.0/24"]
  public_subnets  = ["192.168.1.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
    Name = "terraform-prod-vpc"
  }
}