resource "aws_eip" "static_bastion_host_ip" {
  domain   = "vpc"

  # to retain static ip address
  # lifecycle {
  #   prevent_destroy = true
  # }
}

resource "aws_eip_association" "bastion_host_ip_association" {
  instance_id   = aws_instance.bastion_host.id
  allocation_id = aws_eip.static_bastion_host_ip.id
  depends_on = [aws_instance.bastion_host, aws_eip.static_bastion_host_ip]
}

resource "aws_instance" "bastion_host" {
  ami = var.debian_12_ami.id
  instance_type = var.instance_type
  subnet_id = var.subnet_id
  vpc_security_group_ids = [aws_security_group.ec2_basic_sg.id]
  availability_zone = var.avail_zone
  associate_public_ip_address = true
  user_data_replace_on_change = true
  key_name = var.ssh_key_name
  tags = {
    Name: "${var.env_prefix}-bastion-host"
  }
}

# Null resource to wait for the EIP association and handle provisioning
resource "null_resource" "provision_bastion_host" {
  depends_on = [aws_eip_association.bastion_host_ip_association]
  # runs if bastion_host is recreated
  lifecycle {
      replace_triggered_by = [
        aws_instance.bastion_host.id
      ]
  }
  connection {
    type = "ssh"
    host = aws_eip.static_bastion_host_ip.public_ip
    user = "admin"
    private_key = file(var.private_key_location)
  }

  # copy ssh keys to bastion host
  provisioner "file" {
    source = var.private_key_location
    destination = "/home/admin/.ssh/${var.private_key_name}"
  }
  provisioner "file" {
    source = var.public_key_location
    destination = "/home/admin/.ssh/${var.public_key_name}"
  }

  provisioner "file" {
    source = "payload/mount_efs_drive.sh"
    destination = "/home/admin/mount_efs_drive.sh"
  }

  provisioner "remote-exec" {
    inline = [
        "sudo chmod 400 /home/admin/.ssh/${var.public_key_name}",
        "sudo chmod 400 /home/admin/.ssh/${var.private_key_name}",
        "sudo chmod u+x /home/admin/mount_efs_drive.sh",
      ]
  }
}
