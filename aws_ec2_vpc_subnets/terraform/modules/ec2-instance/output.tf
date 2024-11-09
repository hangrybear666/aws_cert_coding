output "debian_12_ami" {
  value = data.aws_ami.debian-12-image
}
output "ec2_instance" {
  value = [for instance in aws_instance.dev_instance : instance]
}
output "ssh_key_name" {
  value = aws_key_pair.ssh_key.key_name
}
output "ec2_private_sg_id" {
  value = aws_security_group.ec2_private_sg.id
}