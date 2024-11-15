output "alb_to_private_ec2_security_group" {
  value = aws_security_group.ec2_alb_sg
  description = "Security Group of the ALB forwarding to EC2 instances in private subnets"
}