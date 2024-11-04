output "ec2-private_ips" {
  value = [for instance in module.dev_ec2_instances.ec2_instance : instance.private_ip]
  description = "List of public IPs of the EC2 instances"
}

output "bastion_host_ssh_command" {
  value =  "ssh -i ${var.private_key_location} admin@${module.bastion_host_instance.bastion_host_public_ip}"
  description = "SSH command for accessing the Bastion Host"
}
