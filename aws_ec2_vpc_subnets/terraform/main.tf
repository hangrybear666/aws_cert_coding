provider "aws" {}

resource "aws_vpc" "dev_vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name: "${var.env_prefix}-vpc"
  }
}

module "dev_subnets" {
  source = "./modules/subnet"
  public_subnet_cidr_block = var.public_subnet_cidr_block
  private_subnet_cidr_block = var.private_subnet_cidr_block
  avail_zone = var.avail_zone
  env_prefix = var.env_prefix
  aws_vpc = aws_vpc.dev_vpc
}

module "dev_ec2_instances" {
  source = "./modules/ec2-instance"
  instance_count = var.instance_count
  my_ips = var.my_ips
  env_prefix = var.env_prefix
  public_key_location = var.public_key_location
  private_key_location = var.private_key_location
  instance_type = var.instance_type
  avail_zone = var.avail_zone
  subnet_id = module.dev_subnets.aws_subnet_private.id
  aws_vpc = aws_vpc.dev_vpc
}
