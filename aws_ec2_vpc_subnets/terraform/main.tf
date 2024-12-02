provider "aws" {}

module "vpcs" {
  source = "./modules/vpc"
  cidr_block                    = var.dev_vpc_cidr_block
  env_prefix                    = var.env_prefix
}

# public subnet (with IGW and NAT GW) / private subnet for ec2 instances
module "dev_subnets" {
  source = "./modules/subnet"
  public_subnet_cidr_block      = var.public_subnet_cidr_block
  private_subnet_cidr_block_az1 = var.private_subnet_cidr_block_az1
  private_subnet_cidr_block_az2 = var.private_subnet_cidr_block_az2
  avail_zone_1                  = var.avail_zone_1
  avail_zone_2                  = var.avail_zone_2
  env_prefix                    = var.env_prefix
  aws_vpc                       = module.vpcs.dev_vpc
}

module "load_balancing" {
  source = "./modules/load_balancing"
  # ALB has to live in 2-n availability zones. It ALSO has to live in at least one public subnet for internet access
  # Unfortunately, my ec2 instances in the private subnet reside in the same AZ as my public subnet, so we have to create another subnet in AZ2
  aws_subnets                     = [module.dev_subnets.aws_subnet_private_az2, module.dev_subnets.aws_subnet_public]
  private_ec2_subnet_cidr_block   = var.private_subnet_cidr_block_az1
  env_prefix                      = var.env_prefix
  aws_vpc                         = module.vpcs.dev_vpc
  domain_name                     = var.domain_name
  ec2_instances                   = module.dev_ec2_instances.ec2_instances
}

// EFS Network File System
module "elastic_file_system" {
  source = "./modules/efs_storage"
  env_prefix                      = var.env_prefix
  private_subnet_id               = module.dev_subnets.aws_subnet_private_az1.id
  aws_vpc                         = module.vpcs.dev_vpc
  bastion_host_sec_grp_id         = module.bastion_host_instance.bastion_host_sg_id
  ec2_instance_sec_grp_id         = module.dev_ec2_instances.ec2_private_sg_id
}

# ec2 instances in private subnet
module "dev_ec2_instances" {
  source = "./modules/ec2_instance"
  instance_count                    = var.ec2_instance_count
  instance_type                     = var.ec2_instance_type
  bastion_host_private_ip           = module.bastion_host_instance.bastion_host_private_ip
  bastion_host_public_ip            = module.bastion_host_instance.bastion_host_public_ip
  env_prefix                        = var.env_prefix
  public_key_location               = var.public_key_location
  private_key_location              = var.private_key_location
  aws_vpc                           = module.vpcs.dev_vpc
  avail_zone                        = var.avail_zone_1
  alb_security_group                = module.load_balancing.alb_to_private_ec2_security_group
  subnet_id                         = module.dev_subnets.aws_subnet_private_az1.id
}

# bastion host in public subnet for ssh tunneling to ec2 instance from external ip
module "bastion_host_instance" {
  source = "./modules/bastion_host_instance"
  instance_type                     = var.bastion_host_instance_type
  my_ips                            = var.my_ips
  env_prefix                        = var.env_prefix
  ssh_key_name                      = module.dev_ec2_instances.ssh_key_name
  debian_12_ami                     = module.dev_ec2_instances.debian_12_ami
  private_key_location              = var.private_key_location
  private_key_name                  = var.private_key_name
  public_key_location               = var.public_key_location
  public_key_name                   = var.public_key_name
  aws_vpc                           = module.vpcs.dev_vpc
  avail_zone                        = var.avail_zone_1
  subnet_id                         = module.dev_subnets.aws_subnet_public.id
}
