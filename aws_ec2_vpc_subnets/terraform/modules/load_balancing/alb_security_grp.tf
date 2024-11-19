resource "aws_security_group" "ec2_alb_sg" {
  name = "ALB_to_EC2_SecurityGroup"
  description = "ALB to private EC2 subnet Security Group"
  vpc_id = var.aws_vpc.id
  tags = {
    Name: "${var.env_prefix}-alb-ec2-sg"
  }
}

# resource "aws_vpc_security_group_ingress_rule" "public_http_access" {
#   security_group_id = aws_security_group.ec2_alb_sg.id

#   cidr_ipv4   = "0.0.0.0/0"
#   from_port   = 80
#   to_port     = 80
#   ip_protocol = "tcp"
# }

resource "aws_vpc_security_group_ingress_rule" "public_https_access" {
  security_group_id = aws_security_group.ec2_alb_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "outbound_access" {
  security_group_id = aws_security_group.ec2_alb_sg.id

  #             __               __
  #  |  |  /\  |__) |\ | | |\ | / _`
  #  |/\| /~~\ |  \ | \| | | \| \__>
  # this could result in connection issues, likely due to internet egress being prohibited.
  # My idea is to limit egress to only ec2 instance targets within the private subnet
  cidr_ipv4   = var.private_ec2_subnet_cidr_block
  # cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "-1"
}
