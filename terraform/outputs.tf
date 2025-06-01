output "ssh_command" {
  value = "ssh ${var.vm_admin_username}@${module.vm.pub_ip}"
  description = "SSH command for connecting to VM"
}

output "vm_pub_ip" {
  value = module.vm.pub_ip
}

output "admin_username" {
  value = var.vm_admin_username
}
