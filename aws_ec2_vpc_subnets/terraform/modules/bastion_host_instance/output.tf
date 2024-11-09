output "bastion_host_private_ip" {
  value = aws_instance.bastion_host.private_ip
}
output "bastion_host_public_ip" {
  value = aws_eip.static_bastion_host_ip.public_ip
}
output "bastion_host_sg_id" {
  value = aws_security_group.ec2_basic_sg.id
}