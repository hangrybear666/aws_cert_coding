output "efs_dns_name" {
  value = aws_efs_file_system.network_file_system.dns_name
}
output "efs_private_ip" {
  value = data.aws_efs_mount_target.network_file_system.ip_address
}