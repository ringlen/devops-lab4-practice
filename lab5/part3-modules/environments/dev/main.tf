terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"

  # Мок: фіктивні облікові дані, без звернень до реального AWS
  access_key                  = "mock"
  secret_key                  = "mock"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
}

module "vpc" {
  source = "../../modules/vpc"

  environment    = "dev"
  vpc_cidr       = "10.0.0.0/16"
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]

  # Мок: зони вказано явно, щоб не робити запит до AWS
  availability_zones = ["us-east-1a", "us-east-1b"]
}

module "web_server" {
  source = "../../modules/ec2"

  environment   = "dev"
  vpc_id        = module.vpc.vpc_id
  subnet_id     = module.vpc.public_subnet_ids[0]
  instance_type = "t3.micro"

  # Мок: умовний AMI, щоб не робити запит до AWS
  ami_id = "ami-0c55b159cbfafe1f0"
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "web_server_ip" {
  value = module.web_server.public_ip
}