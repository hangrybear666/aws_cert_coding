output "aws_subnet_private" {
  value = aws_subnet.dev_public_subnet
}
output "aws_subnet_public" {
  value = aws_subnet.dev_private_subnet
}
output "nat_gateway_ip" {
  value = aws_eip.nat_gw_eip.public_ip
}