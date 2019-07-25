####################################__________________________________________________________
#### vSphere Provider and login ####
####################################
provider "vsphere" {
  user           = "vCenter User Name"
  password       = "vCenter Password"
  vsphere_server = "Vcenter Server"

  # if you have a self-signed cert
  allow_unverified_ssl = true
}




####################################__________________________________________________________
#### Data for vSphere Resources ####
####################################
data "vsphere_datacenter" "dc" {
  name = "BenNet" ## VMware Data Center for Resources to reside in 
}
data "vsphere_datastore" "datastore" {
  name          = "BenNetESXI Local Storage M2 1TB" ## VMware Data Store for Resources to reside in 
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}
data "vsphere_resource_pool" "pool" {
  name          = "BenNetDock-Swarm" ## VMware Resource Pool for Resources to reside in 
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}
data "vsphere_network" "network" {
  name          = "BenNetDock_Network" ## VMware Network for Resources to reside on
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}




################################################______________________________________________
#### Docker Swarm Master Manager Informtion ####
################################################

#### IP information to for Master Manager 
variable "master_manager_ip_address" {default = "192.168.9.150"} ### This must be the address you initilized the Swarm from 

#### Name Information
variable "master_manager_vm_name" {default = "BenNetDockManager-0"}
variable "master_manager_host_name" {default = "bennetdockmanager-0"}

####------------------------------------------------
#### Template Information 
data "vsphere_virtual_machine" "master-management-template" {
  name          = "Ubuntu16DockManager-Template"  # name of VMware template to use
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}
####------------------------------------------------
#### Resource Information 
variable "master_manager_cpu" {default = 2}
variable "master_manager_mem" {default = 2048}
variable "master_manager_netmask" {default = "24"}





####################################################__________________________________________
#### Docker Swarm Additional Manager Informtion ####
####################################################

#### Name Information
variable "manager_vm_name" {default = "BenNetDockManager-"}
variable "manager_host_name" {default = "bennetdockmanager-"}

####------------------------------------------------
#### Template Information 
data "vsphere_virtual_machine" "management-template" {
  name          = "Ubuntu16DockWorker-Template" # name of VMware template to use
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}
####------------------------------------------------
#### Resource Information 
variable "manager_count" {default = 0} ### Number of Additional Docker Swarm Manager Machines ####
variable "manager_cpu" {default = 2}
variable "manager_mem" {default = 2048}
variable "manager_netmask" {default = "24"}
variable "manager_join_token" {default = "Example-Manager-Token"}




#########################################_____________________________________________________
#### Docker Swarm Worker Information ####
#########################################

#### Name Information
variable "worker_vm_name" {default = "BenNetDockWorker-"}
variable "worker_host_name" {default = "bennetdockworker-"}

####------------------------------------------------
#### Template Information 
  data "vsphere_virtual_machine" "worker-template" {
  name          = "Ubuntu16DockWorker-Template" # name of VMware template to use
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}
####------------------------------------------------
#### Resource Information 
variable "worker_count" {default = 2} ### Number of Docker Swarm Worker Machines ####
variable "worker_cpu" {default = 2}
variable "worker_mem" {default = 2048}
variable "worker_netmask" {default = "24"}
variable "worker_join_token" {default = "Example-Worker-Token"}



#############################_________________________________________________________________
#### Global Networks Info ###
#############################
variable "ipv4_netmask" {default = 24} # manager IP range
variable "man_ip_range" {default = "192.168.9.15"} # manager IP range
variable "work_ip_range" {default = "192.168.9.16"} # worker IP range
variable "default_gateway" {default = "192.168.9.100"} # defualt gateway
variable "dns_server" {default = "192.168.10.115"} # DNS server
variable "domain" {default = "bennetdock.com"} # Domain 



##########################____________________________________________________________________
#### SSH Creditials   ####
##########################

#### Template SSH Password
variable "ssh-user" {default = "SSH-UserName"}
variable "ssh-password" {default = "SSH-Password"}