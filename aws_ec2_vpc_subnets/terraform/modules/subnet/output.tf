output "aws_subnet_private_az1" {
  value = aws_subnet.dev_private_subnet_az1
}
output "aws_subnet_private_az2" {
  value = aws_subnet.dev_private_subnet_az2
}
output "aws_subnet_public" {
  value = aws_subnet.dev_public_subnet
}
output "nat_gateway_ip" {
  value = aws_eip.nat_gw_eip.public_ip
}