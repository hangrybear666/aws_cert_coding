resource "aws_security_group" "ec2_basic_sg" {
  name = "EC2BasicSecurityGroup"
  description = "Basic Security Group for Bastion Host machine"
  vpc_id = var.aws_vpc.id
  ingress {
    cidr_blocks = var.my_ips
    from_port = 22
    to_port = 22
    protocol = "tcp"
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    to_port = 0
    protocol = "-1"
  }
  tags = {
    Name: "${var.env_prefix}-basic-sg"
  }
}

resource "aws_instance" "bastion_host" {
  ami = var.debian_12_ami.id
  instance_type = var.instance_type

  subnet_id = var.subnet_id
  vpc_security_group_ids = [aws_security_group.ec2_basic_sg.id]
  availability_zone = var.avail_zone

  associate_public_ip_address = true
  key_name = var.ssh_key_name

  user_data_replace_on_change = true
  connection {
    type = "ssh"

    host = self.public_ip
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

  provisioner "remote-exec" {
    inline = [
        "sudo chmod 400 /home/admin/.ssh/${var.public_key_name}",
        "sudo chmod 400 /home/admin/.ssh/${var.private_key_name}"
      ]
  }

  tags = {
    Name: "${var.env_prefix}-bastion-host"
  }
}
