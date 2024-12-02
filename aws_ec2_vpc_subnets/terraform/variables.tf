variable "dev_vpc_cidr_block" {
  description = "CIDR block for the Dev VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_block" {
  description = "CIDR block for the public subnet within the VPC"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr_block_az1" {
  description = "CIDR block for the private subnet within AZ1"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_subnet_cidr_block_az2" {
  description = "CIDR block for the private subnet within AZ2"
  type        = string
  default     = "10.0.3.0/24"
}

variable "avail_zone_1" {
  description = "AWS availability 1 zone where the resources will be launched"
  type        = string
  default     = "eu-central-1a"
}
variable "avail_zone_2" {
  description = "AWS availability 2 zone where the resources will be launched"
  type        = string
  default     = "eu-central-1b"
}

variable "env_prefix" {
  description = "Application Prefix for e.g. tagging resources"
  type        = string
  default     = "dev"
}

variable "my_ips" {
  description = "Your public IP for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Update to your IP (e.g. "203.0.113.0/32") for security
}

variable "bastion_host_instance_type" {
  description = "The bastion host instance type"
  type        = string
  default     = "t2.micro"
}
variable "ec2_instance_type" {
  description = "The EC2 instance type to use for private instances"
  type        = string
  default     = "t2.micro"
}
variable "ec2_instance_count" {
  description = "The EC2 instances you desire"
  type        = number
  default     = 1
}
variable "public_key_location" {
  description = "Path to your public SSH key"
  type        = string
  default     = "~/.ssh/id_rsa.pub"  # Update to the correct key path if necessary
}

variable "private_key_location" {
  description = "Path to your private SSH key"
  type        = string
  default     = "~/.ssh/id_rsa"  # Update to the correct key path if necessary
}
variable "public_key_name" {
  description = "Name of your Public Key File"
  type        = string
  default     = "id_rsa.pub"  # Update to the correct name if necessary
}
variable "private_key_name" {
  description = "Name of your Private Key File"
  type        = string
  default     = "id_rsa"  # Update to the correct name if necessary
}
variable "domain_name" {
  description = "Name of your root domain where a Route 53 TLS certificate has been issued for HTTPS enabled ALB"
  type        = string
  default     = "fiscalismia.com"  # Update to the correct name if necessary
}
