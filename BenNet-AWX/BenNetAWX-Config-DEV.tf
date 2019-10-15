
#################################################################################################################################################
#### Build BenNetAWX ##################################################################################################################
#################################################################################################################################################

#### The Docker Swarm must be init from this machine before turning into a template. You must also keep the IP (192.168.8.150) address the same after cloneing/terraforming for docker routing mesh network to work.

#### Name of machine to be cloned
resource "vsphere_virtual_machine" "BenNetMachine" {
  name             = "${var.template_vm_name}"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"
####--------------------------------------------------------------------------------------------------
#### Template Resource info
  num_cpus = "${var.template_cpu}"
  memory   = "${var.template_mem}"
  guest_id = "${data.vsphere_virtual_machine.vmware-template.guest_id}"
  scsi_type = "${data.vsphere_virtual_machine.vmware-template.scsi_type}"
  wait_for_guest_net_timeout = 1       # This setting makes the master manager machine spin up slower than the worker so the swarm will distrubute the containers evenly
  wait_for_guest_net_routable = true
  wait_for_guest_ip_timeout = 1
####--------------------------------------------------------------------------------------------------
#### Template Network Info
  network_interface {
    network_id   = "${data.vsphere_network.network.id}"
  }
####--------------------------------------------------------------------------------------------------
#### Template Disk info
  disk {
    name             = "${var.template_vm_name}.vmdk"
    size             = "${data.vsphere_virtual_machine.vmware-template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.vmware-template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.vmware-template.disks.0.thin_provisioned}"
    
  }
####--------------------------------------------------------------------------------------------------
#### SSH Creds to the machine
  connection {
        user = "${var.ssh-user}"
        password = "${var.ssh-password}"
        host = "${var.template_ip_address}"
  }   
####--------------------------------------------------------------------------------------------------
#### Template ID  
  clone {
    template_uuid = "${data.vsphere_virtual_machine.vmware-template.id}"

#### VMware Guest Customization (Only working on Ubuntu 16.04 7/1/19)
    customize {
      network_interface {
        ipv4_address = "${var.template_ip_address}"
        ipv4_netmask = "${var.ipv4_netmask}"
      } 
      ipv4_gateway = "${var.default_gateway}"
      dns_server_list = [ "${var.dns_server}" ]
      linux_options {
        host_name = "${var.template_host_name}"
        domain    = "${var.domain}"
        
      }
    }
  }
####-------------------------------------------------------------------------------------------------- 
#### Remote SSH into machine and run commands 

#### This step git clones the repo containing the docker compose files that are subseqitly deployed via a stack deploy command for each type of stack
    provisioner "remote-exec" {
      inline = [
        "echo ${var.sudo-password} | sudo -S apt -y install build-essential"
        ,"sudo apt install software-properties-common -y"
        ,"sudo apt-add-repository --yes --update ppa:ansible/ansible"
        ,"sudo apt install ansible -y"
        ,"sudo apt install docker.io -y"
        ,"sudo apt install python-pip -y"
        ,"sudo apt install nodejs npm -y"
        ,"sudo npm install npm --global"
        ,"sudo pip install pyvmomi"
        ,"sudo pip install passlib"
        ,"sudo apt update && apt upgrade -y"
        ,"git clone https://github.com/ansible/awx.git"
        ,"sudo ansible-playbook -i /home/administrator/awx-inventory/inventory-DEV.yml /home/administrator/awx/installer/install.yml"
      ]
    }

}
####____________________________________________________________________________________________________________________________________________________________________________________