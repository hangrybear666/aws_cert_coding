resource "aws_security_group" "ec2_private_sg" {
  name = "EC2PrivateSecurityGroup"
  description = "Private Security Group for Dev EC2 machine"
  vpc_id = var.aws_vpc.id
  tags = {
    Name: "${var.env_prefix}-private-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http_access" {
  security_group_id = aws_security_group.ec2_private_sg.id

  referenced_security_group_id = var.alb_security_group.id
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "ssh_from_bastion_host" {
  security_group_id = aws_security_group.ec2_private_sg.id

  cidr_ipv4   = "${var.bastion_host_private_ip}/32"
  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"
}

# exists by default
# resource "aws_vpc_security_group_egress_rule" "outbound_access" {
#   security_group_id = aws_security_group.ec2_private_sg.id

#   cidr_ipv4   = "0.0.0.0/0"
#   from_port   = 0
#   to_port     = 0
#   ip_protocol = "-1"
# }