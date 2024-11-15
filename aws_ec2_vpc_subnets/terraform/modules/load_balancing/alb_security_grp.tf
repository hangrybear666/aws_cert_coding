resource "aws_security_group" "ec2_alb_sg" {
  name = "ALB_to_EC2_SecurityGroup"
  description = "ALB to private EC2 subnet Security Group"
  vpc_id = var.aws_vpc.id
  tags = {
    Name: "${var.env_prefix}-alb-ec2-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "public_http_access" {
  security_group_id = aws_security_group.ec2_alb_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "outbound_access" {
  security_group_id = aws_security_group.ec2_alb_sg.id

  cidr_ipv4   = var.private_subnet_cidr_block
  ip_protocol = "-1"
}
