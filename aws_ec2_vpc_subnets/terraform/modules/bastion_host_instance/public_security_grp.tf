resource "aws_security_group" "ec2_basic_sg" {
  name = "EC2BasicSecurityGroup"
  description = "Basic Security Group for Bastion Host machine"
  vpc_id = var.aws_vpc.id
  tags = {
    Name: "${var.env_prefix}-basic-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh_from_my_ips" {
  security_group_id = aws_security_group.ec2_basic_sg.id
  for_each = toset(var.my_ips)
  cidr_ipv4   = "${each.value}"
  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "outbound_access" {
  security_group_id = aws_security_group.ec2_basic_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}