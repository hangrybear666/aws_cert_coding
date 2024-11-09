resource "aws_vpc" "dev_vpc" {
  cidr_block = var.cidr_block
  tags = {
    Name: "${var.env_prefix}-dev-vpc"
  }
}