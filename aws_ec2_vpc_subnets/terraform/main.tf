provider "aws" {}

module "vpcs" {
  source = "./modules/vpc"
  cidr_block = var.dev_vpc_cidr_block
  env_prefix = var.env_prefix
}

# creates public subnet (with igw and nat gw) and private subnet for ec2 instances
module "dev_subnets" {
  source = "./modules/subnet"
  public_subnet_cidr_block = var.public_subnet_cidr_block
  private_subnet_cidr_block = var.private_subnet_cidr_block
  avail_zone = var.avail_zone
  env_prefix = var.env_prefix
  aws_vpc = module.vpcs.dev_vpc
}

// Network File System
module "elastic_file_system" {
  source = "./modules/efs_storage"
  env_prefix = var.env_prefix
  private_subnet_id = module.dev_subnets.aws_subnet_private.id
  aws_vpc = module.vpcs.dev_vpc
  bastion_host_sec_grp_id = module.bastion_host_instance.bastion_host_sg_id
  ec2_instance_sec_grp_id = module.dev_ec2_instances.ec2_private_sg_id
}

# ec2 instances in private subnet
module "dev_ec2_instances" {
  source = "./modules/ec2-instance"
  instance_count = var.instance_count
  instance_type = var.instance_type
  bastion_host_private_ip = module.bastion_host_instance.bastion_host_private_ip
  bastion_host_public_ip = module.bastion_host_instance.bastion_host_public_ip
  env_prefix = var.env_prefix
  public_key_location = var.public_key_location
  private_key_location = var.private_key_location
  aws_vpc = module.vpcs.dev_vpc
  avail_zone = var.avail_zone
  subnet_id = module.dev_subnets.aws_subnet_private.id
}

# bastion host in public subnet for ssh tunneling to ec2 instance from external ip
module "bastion_host_instance" {
  source = "./modules/bastion_host_instance"
  instance_type = "t2.micro"
  my_ips = var.my_ips
  env_prefix = var.env_prefix
  ssh_key_name = module.dev_ec2_instances.ssh_key_name
  debian_12_ami = module.dev_ec2_instances.debian_12_ami
  private_key_location = var.private_key_location
  private_key_name = var.private_key_name
  public_key_location = var.public_key_location
  public_key_name = var.public_key_name
  aws_vpc = module.vpcs.dev_vpc
  avail_zone = var.avail_zone
  subnet_id = module.dev_subnets.aws_subnet_public.id
}
