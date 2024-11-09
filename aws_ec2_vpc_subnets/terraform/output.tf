output "ec2-private_ips" {
  value = [for instance in module.dev_ec2_instances.ec2_instance : instance.private_ip]
  description = "List of public IPs of the EC2 instances."
}

output "bastion_host_ssh_command" {
  value =  "ssh -i ${var.private_key_location} admin@${module.bastion_host_instance.bastion_host_public_ip}"
  description = "SSH command for accessing the Bastion Host."
}

output "ec2_private_ssh_command" {
  value = [for instance in module.dev_ec2_instances.ec2_instance : "admin@bastion_host_ip: ssh -i ${var.private_key_location} admin@${instance.private_ip}"]
  description = "SSH commands from within Bastion Host to access private subnet instances."
}

output "complete_commands" {
  value = [for instance in module.dev_ec2_instances.ec2_instance : <<EOF
#   __   ___ ___       __             __  ___            __   ___
#  /__` |__   |  |  | |__)    | |\ | /__`  |   /\  |\ | /  ` |__
#  .__/ |___  |  \__/ |       | | \| .__/  |  /~~\ | \| \__, |___
ssh -i ${var.private_key_location} admin@${module.bastion_host_instance.bastion_host_public_ip}
bash /home/admin/mount_efs_drive.sh ${module.elastic_file_system.efs_private_ip}
ssh -i ${var.private_key_location} admin@${instance.private_ip}
bash /home/admin/mount_efs_drive.sh ${module.elastic_file_system.efs_private_ip}
bash /home/admin/install-git-on-debian-ec2.sh
EOF
]
  description = "complete SSH commands to setup instance"
}
