resource "aws_key_pair" "ssh_key" {
  key_name = "tf-server-key"
  public_key = file(var.public_key_location)
}

resource "aws_instance" "dev_instance" {
  ami = data.aws_ami.debian-12-image.id
  instance_type = var.instance_type
  count = var.instance_count

  subnet_id = var.subnet_id
  vpc_security_group_ids = [aws_security_group.ec2_private_sg.id]
  availability_zone = var.avail_zone

  associate_public_ip_address = false
  key_name = aws_key_pair.ssh_key.key_name

  # alternative is to use an existing key from AWS and use its respective private key .pem file to ssh into the server
  # key_name ="hangrybear_dev-one"

  # the problem with user data is no logging in terraform, it is also not possible to pass multiple files
  # user_data = file("payload/install-git-on-debian-ec2.sh")

  user_data_replace_on_change = true
  // WARNING: Provisioners are NOT recommended by terraform as it breaks the principle of idempotency
  connection {
    type = "ssh"

    bastion_host = var.bastion_host_public_ip
    bastion_user = "admin"
    bastion_private_key = file(var.private_key_location)

    host = self.private_ip
    user = "admin"
    private_key = file(var.private_key_location)
  }

  # copies all files in payload folder
  provisioner "file" {
    source      = "payload/"
    destination = "/home/admin"
  }

  provisioner "remote-exec" {
    inline = [
        "sudo chmod u+x /home/admin/install-git-on-debian-ec2.sh",
        "sudo chmod u+x /home/admin/expose_html_via_nginx.sh",
        "sudo chmod u+x /home/admin/mount_efs_drive.sh",
        # "/bin/bash /home/admin/install-git-on-debian-ec2.sh"
      ]
  }

  tags = {
    Name: "${var.env_prefix}-server",
    InstanceNum: "${var.env_prefix}-${count.index + 1}"
  }
}
