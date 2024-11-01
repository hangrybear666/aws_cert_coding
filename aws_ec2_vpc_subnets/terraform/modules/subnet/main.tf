resource "aws_subnet" "dev_public_subnet" {
  vpc_id = var.aws_vpc.id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name: "${var.env_prefix}-subnet-public"
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

resource "aws_route_table_association" "rtb-subnet-association" {
  subnet_id = aws_subnet.dev_public_subnet.id
  route_table_id = aws_route_table.dev_public_route_table.id
}