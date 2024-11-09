data "aws_efs_mount_target" "network_file_system" {
  file_system_id = aws_efs_file_system.network_file_system.id
  depends_on = [aws_efs_file_system.network_file_system]
}

# lives in different vpc so can't trivially be added to efs mnt
data "aws_security_group" "ec2_one_admin_machine_sec_grp" {
  filter {
    name   = "group-name"
    values = ["launch-wizard-2"]
  }
}