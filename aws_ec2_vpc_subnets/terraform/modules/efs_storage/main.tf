
resource "aws_efs_file_system" "network_file_system" {
  creation_token = "${var.env_prefix}-efs"
  performance_mode = "generalPurpose"
  throughput_mode = "bursting"
  encrypted = "true"
  lifecycle_policy {
    transition_to_ia = "AFTER_14_DAYS"
  }
  # not supported for bursting throughput
  # lifecycle_policy {
  #   transition_to_primary_storage_class = "AFTER_1_ACCESS"
  #   transition_to_archive = "AFTER_30_DAYS"
  # }
  tags = {
    Name = "${var.env_prefix}-nfs"
  }
}
resource "aws_efs_mount_target" "efs_mnt_bastion_host" {
  file_system_id  = aws_efs_file_system.network_file_system.id
  subnet_id = var.private_subnet_id
  security_groups = [aws_security_group.efs_access.id]
}

resource "aws_security_group" "efs_access" {
  name = "efs-access-sg"
  description = "Security Group for EFS allowing access only from other VPC Security Groups."
  vpc_id = var.aws_vpc.id

  ingress {
    security_groups = [var.bastion_host_sec_grp_id, var.ec2_instance_sec_grp_id]
    from_port = 2049
    to_port = 2049
    protocol = "tcp"
  }

  egress {
    security_groups = [var.bastion_host_sec_grp_id, var.ec2_instance_sec_grp_id]
    from_port = 0
    to_port = 0
    protocol = "-1"
  }
  tags = {
    Name: "${var.env_prefix}-efs-access-sg"
  }
}
