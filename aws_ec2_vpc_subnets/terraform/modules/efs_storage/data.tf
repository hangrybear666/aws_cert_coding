data "aws_efs_mount_target" "network_file_system" {
  file_system_id = aws_efs_file_system.network_file_system.id
}
