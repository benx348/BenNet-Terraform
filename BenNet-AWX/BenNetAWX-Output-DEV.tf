output "Output-VM-IP-Adress" {
   value = "${vsphere_virtual_machine.BenNetMachine.*.default_ip_address}"
}

