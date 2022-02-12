provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name = "prod-vpc"
  cidr = "192.168.0.0/23"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["192.168.0.0/24"]
  public_subnets  = ["192.168.1.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  public_subnet_tags = {
    Name = "public-subnet"
  }

  private_subnet_tags = {
    Name = "private-subnet"
  }

  igw_tags = {
    Name = "igw-terraform"
  }

  nat_gateway_tags = {
    Name = "natigw-terraform"
  }

  public_route_table_tags = {
    Name = "public-rt"
  }

  private_route_table_tags = {
    Name = "private-rt"
  }

  tags = {
    Terraform = "true"
    Environment = "dev"
    Name = "terraform-prod-vpc"
  }
}

module "public-web-server-sg" {
  source = "terraform-aws-modules/security-group/aws//modules/http-80"

  name        = "public-web-server-sg"
  description = "Security group for web-server with HTTP ports open within VPC"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH Connectivity"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "laravel-server-terraform"

  ami                    = data.ubuntu-ami.id[0]
  instance_type          = "t2.micro"
  key_name               = data.aws_key_pair.key_name
  monitoring             = true
  vpc_security_group_ids = [module.public-web-server-sg.security_group_id]
  subnet_id              = module.vpc.private_subnets[0]

  tags = {
    Terraform   = "true"
    Environment = "prod"
  }
}