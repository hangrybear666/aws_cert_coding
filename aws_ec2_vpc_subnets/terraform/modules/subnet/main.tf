resource "aws_subnet" "dev_public_subnet" {
  vpc_id = var.aws_vpc.id
  cidr_block = var.public_subnet_cidr_block
  availability_zone = var.avail_zone_1
  tags = {
    Name: "${var.env_prefix}-subnet-public"
  }
}

resource "aws_subnet" "dev_private_subnet_az1" {
  vpc_id = var.aws_vpc.id
  cidr_block = var.private_subnet_cidr_block_az1
  availability_zone = var.avail_zone_1
  tags = {
    Name: "${var.env_prefix}-subnet-private-az1"
  }
}

resource "aws_subnet" "dev_private_subnet_az2" {
  vpc_id = var.aws_vpc.id
  cidr_block = var.private_subnet_cidr_block_az2
  availability_zone = var.avail_zone_2
  tags = {
    Name: "${var.env_prefix}-subnet-private-az2"
  }
}

resource "aws_internet_gateway" "dev_igw" {
  vpc_id = var.aws_vpc.id
  tags = {
    Name: "${var.env_prefix}-igw"
  }
}

resource "aws_route_table" "dev_public_route_table" {
  vpc_id = var.aws_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev_igw.id
  }
  tags = {
    Name: "${var.env_prefix}-public-route-table"
  }
}

resource "aws_route_table_association" "rtb_subnet_association" {
  subnet_id = aws_subnet.dev_public_subnet.id
  route_table_id = aws_route_table.dev_public_route_table.id
}

resource "aws_eip" "nat_gw_eip" {
  domain   = "vpc"
}

resource "aws_nat_gateway" "dev_public_nat_gateway" {
  allocation_id = aws_eip.nat_gw_eip.id
  subnet_id     = aws_subnet.dev_public_subnet.id

  tags = {
    Name: "${var.env_prefix}-nat-gw"
  }
  depends_on = [aws_internet_gateway.dev_igw]
}

resource "aws_route_table" "nat_gw_route_table" {
  vpc_id = var.aws_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.dev_public_nat_gateway.id
  }
  tags = {
    Name: "${var.env_prefix}-public-route-table"
  }
}

resource "aws_route_table_association" "rtb_nat_gw_association_subnet_az1" {
  subnet_id = aws_subnet.dev_private_subnet_az1.id
  route_table_id = aws_route_table.nat_gw_route_table.id
}

resource "aws_route_table_association" "rtb_nat_gw_association_subnet_az2" {
  subnet_id = aws_subnet.dev_private_subnet_az2.id
  route_table_id = aws_route_table.nat_gw_route_table.id
}