##########################################_________________________________________________________________________________________________________________________________________________________________________________
#### Build BenNetDock Worker Machines ####
##########################################

#### Name of machine to be cloned
resource "vsphere_virtual_machine" "Swarm-Workers" {
  name             = "${var.worker_vm_name}${count.index+1}"
  count            = "${var.worker_count}"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"
####--------------------------------------------------------------------------------------------------
#### Template Resource info
  num_cpus = "${var.worker_cpu}"
  memory   = "${var.worker_mem}"
  guest_id = "${data.vsphere_virtual_machine.worker-template.guest_id}"
  scsi_type = "${data.vsphere_virtual_machine.worker-template.scsi_type}"
  wait_for_guest_net_timeout = 0
  wait_for_guest_net_routable = false
####--------------------------------------------------------------------------------------------------
#### Template Network Info
  network_interface {
    network_id   = "${data.vsphere_network.network.id}"
  }
####--------------------------------------------------------------------------------------------------
#### Template Disk info
  disk {
    name             = "${var.worker_vm_name}${count.index+1}.vmdk"
    size             = "${data.vsphere_virtual_machine.worker-template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.worker-template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.worker-template.disks.0.thin_provisioned}"
  }
####--------------------------------------------------------------------------------------------------
#### SSH Creds to the machine
  connection {
        user = "${var.ssh-user}"
        password = "${var.ssh-password}"
        host = "${var.work_ip_range}${count.index}"
    }
####-------------------------------------------------------------------------------------------------- 
#### Template ID and name from var file
  clone {
    template_uuid = "${data.vsphere_virtual_machine.worker-template.id}"

#### VMware Guest Customization (Only working on Ubuntu 16.04 7/1/19)
    customize {
      network_interface {
        ipv4_address = "${var.work_ip_range}${count.index}"
        ipv4_netmask = "${var.ipv4_netmask}"
      } 
      ipv4_gateway = "${var.default_gateway}"
      dns_server_list = [ "${var.dns_server}" ]
      linux_options {
        host_name = "${var.worker_host_name}${count.index+1}"
        domain    = "${var.domain}"
        
      }
    }
  }
####-------------------------------------------------------------------------------------------------- 
#### Remote SSH into machine and run commands 
#### This command joins a worker node to the Docker Swarm. the Swarm has already been initilized in the manager template so the join token is used from that command 
   provisioner "remote-exec" {
      inline = [
        "docker swarm join --token ${var.worker_join_token} ${var.master_manager_ip_address}:2377"
      ]

 }
}

######################################################_____________________________________________________________________________________________________________________________________________________________________
#### Build BenNetDock Additional Manager Machines ####
######################################################

#### Name of machine to be cloned
resource "vsphere_virtual_machine" "Swarm-Manager" {
  name             = "${var.manager_vm_name}${count.index+1}"
  count            = "${var.manager_count}"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"
####--------------------------------------------------------------------------------------------------
#### Template Resource info
  num_cpus = "${var.worker_cpu}"
  memory   = "${var.worker_mem}"
  guest_id = "${data.vsphere_virtual_machine.worker-template.guest_id}"
  scsi_type = "${data.vsphere_virtual_machine.worker-template.scsi_type}"
  wait_for_guest_net_timeout = 0
  wait_for_guest_net_routable = false
####--------------------------------------------------------------------------------------------------
#### Template Network Info
  network_interface {
    network_id   = "${data.vsphere_network.network.id}"
  }
####--------------------------------------------------------------------------------------------------
#### Template Disk info
  disk {
    name             = "${var.manager_vm_name}${count.index+1}.vmdk"
    size             = "${data.vsphere_virtual_machine.worker-template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.worker-template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.worker-template.disks.0.thin_provisioned}"
  }
####--------------------------------------------------------------------------------------------------
#### SSH Creds to the machine
  connection {
        user = "${var.ssh-user}"
        password = "${var.ssh-password}"
        host = "${var.man_ip_range}${count.index+1}"
    }
####-------------------------------------------------------------------------------------------------- 
#### Template ID and name from var file
  clone {
    template_uuid = "${data.vsphere_virtual_machine.worker-template.id}"

#### VMware Guest Customization (Only working on Ubuntu 16.04 7/1/19)
    customize {
      network_interface {
        ipv4_address = "${var.man_ip_range}${count.index+1}"
        ipv4_netmask = "${var.ipv4_netmask}"
      } 
      ipv4_gateway = "${var.default_gateway}"
      dns_server_list = [ "${var.dns_server}" ]
      linux_options {
        host_name = "${var.manager_host_name}${count.index+1}"
        domain    = "${var.domain}"
        
      }
    }
  }
####-------------------------------------------------------------------------------------------------- 
#### Remote SSH into machine and run commands 
#### This command joins a manager node to the Docker Swarm. 
   provisioner "remote-exec" {
      inline = [
        "docker swarm join --token ${var.manager_join_token} ${var.master_manager_ip_address}:2377"
      ]

 }
}

###################################_________________________________________________________________________________________________________________________________________________________________________________________
#### BenNetDock Manager Master ####
###################################

#### The Docker Swarm must be init from this machine before turning into a template. You must also keep the IP (192.168.8.150) address the same after cloneing/terraforming for docker routing mesh network to work.

#### Name of machine to be cloned
resource "vsphere_virtual_machine" "Swarm-Manager-Master" {
  name             = "${var.master_manager_vm_name}"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"
####--------------------------------------------------------------------------------------------------
#### Template Resource info
  num_cpus = "${var.master_manager_cpu}"
  memory   = "${var.master_manager_mem}"
  guest_id = "${data.vsphere_virtual_machine.master-management-template.guest_id}"
  scsi_type = "${data.vsphere_virtual_machine.master-management-template.scsi_type}"
  wait_for_guest_net_timeout = 1
  wait_for_guest_net_routable = false
####--------------------------------------------------------------------------------------------------
#### Template Network Info
  network_interface {
    network_id   = "${data.vsphere_network.network.id}"
  }
####--------------------------------------------------------------------------------------------------
#### Template Disk info
  disk {
    name             = "${var.master_manager_vm_name}.vmdk"
    size             = "${data.vsphere_virtual_machine.master-management-template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.master-management-template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.master-management-template.disks.0.thin_provisioned}"
    
  }
####--------------------------------------------------------------------------------------------------
#### SSH Creds to the machine
  connection {
        user = "${var.ssh-user}"
        password = "${var.ssh-password}"
        host = "${var.master_manager_ip_address}"
  }   
####--------------------------------------------------------------------------------------------------
#### Template ID  
  clone {
    template_uuid = "${data.vsphere_virtual_machine.master-management-template.id}"

#### VMware Guest Customization (Only working on Ubuntu 16.04 7/1/19)
    customize {
      network_interface {
        ipv4_address = "${var.master_manager_ip_address}"
        ipv4_netmask = "${var.ipv4_netmask}"
      } 
      ipv4_gateway = "${var.default_gateway}"
      dns_server_list = [ "${var.dns_server}" ]
      linux_options {
        host_name = "${var.master_manager_host_name}"
        domain    = "${var.domain}"
        
      }
    }
  }
####-------------------------------------------------------------------------------------------------- 
#### Remote SSH into machine and run commands 

#### This step git clones the repo containing the docker compose files that are subseqitly deployed via a stack deploy command for each type of stack
    provisioner "remote-exec" {
      inline = [
        "git clone --branch PROD https://Example-Git-Repo.git"
        ,"docker stack deploy --compose-file=/home/administrator/BenNet-DockSwarm-StackDeploy/Portainer-Stack-PROD.yml Portainer-Stack-PROD"
        ,"docker stack deploy --compose-file=/home/administrator/BenNet-DockSwarm-StackDeploy/Tor-Stack-PROD.yml Tor-Stack-PROD"
        ,"docker stack deploy --compose-file=/home/administrator/BenNet-DockSwarm-StackDeploy/Guac-Stack-PROD.yml Guac-Stack-PROD"
        ,"docker stack deploy --compose-file=/home/administrator/BenNet-DockSwarm-StackDeploy/Unifi-Stack-PROD.yml Unifi-Stack-PROD"
        ,"docker stack deploy --compose-file=/home/administrator/BenNet-DockSwarm-StackDeploy/Plex-Stack-PROD.yml Plex-Stack-PROD"
      ]
    }

}
####____________________________________________________________________________________________________________________________________________________________________________________

