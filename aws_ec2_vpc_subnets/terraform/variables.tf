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

variable "private_subnet_cidr_block" {
  description = "CIDR block for the private subnet within the VPC"
  type        = string
  default     = "10.0.2.0/24"
}

variable "avail_zone" {
  description = "AWS availability zone where the resources will be launched"
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

variable "instance_type" {
  description = "The EC2 instance type to use"
  type        = string
  default     = "t2.micro"
}
variable "instance_count" {
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
