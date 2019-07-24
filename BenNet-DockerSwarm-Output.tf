output "_Swarm-Manager-Master-IP_" {
   value = "${vsphere_virtual_machine.Swarm-Manager-Master.*.default_ip_address}"
}
#-----------------------------------------------------------------------------------
output "Swarm-Manager-IP" {
   value = "${vsphere_virtual_machine.Swarm-Manager.*.default_ip_address}"
}
#-----------------------------------------------------------------------------------
output "Swarm-Worker-IP" {
   value = "${vsphere_virtual_machine.Swarm-Workers.*.default_ip_address}"
}
