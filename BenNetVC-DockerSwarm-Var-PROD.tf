####################################__________________________________________________________
#### vSphere Provider and login ####
####################################
provider "vsphere" {
  user           = "VCENTER USER NAME"
  password       = "VCENTER PASSWORD"
  vsphere_server = "VCENTER Server"

  # if you have a self-signed cert
  allow_unverified_ssl = true
}
####################################__________________________________________________________
#### Data for vSphere Resources ####
####################################
data "vsphere_datacenter" "dc" {
  name = "BenNet"
}
data "vsphere_datastore" "datastore" {
  name          = "BenNetESXI Local Storage M2 1TB"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}
data "vsphere_datastore" "iso_datastore" {
  name          = "BenNetESXI Local Storage M2 1TB"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}
data "vsphere_resource_pool" "pool" {
  name          = "Docker-Swarm-Test"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}
data "vsphere_network" "network" {
  name          = "BenNetTest_Network"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

################################################______________________________________________
#### Docker Swarm Master Manager Informtion ####
################################################
data "vsphere_virtual_machine" "master-management-template" {
  name          = "Ubuntu16DockManager-Template"  # name of VMware template to use
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}
variable "master_manager_cpu" {default = 2}
variable "master_manager_mem" {default = 2048}
variable "master_manager_gateway" {default = "192.168.8.100"}
variable "master_manager_netmask" {default = "24"}
####################################################__________________________________________
#### Docker Swarm Additional Manager Informtion ####
####################################################
data "vsphere_virtual_machine" "management-template" {
  name          = "Ubuntu16DockWorker-Template" # name of VMware template to use
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}
variable "manager_count" {default = 0} ### Number of Additional Docker Swarm Manager Machines ####
variable "manager_cpu" {default = 2}
variable "manager_mem" {default = 2048}
variable "manager_gateway" {default = "192.168.8.100"}
variable "manager_netmask" {default = "24"}
#########################################_____________________________________________________
#### Docker Swarm Worker Information ####
#########################################
  data "vsphere_virtual_machine" "worker-template" {
  name          = "Ubuntu16DockWorker-Template" # name of VMware template to use
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}
variable "worker_count" {default = 2} ### Number of Docker Swarm Worker Machines ####
variable "worker_cpu" {default = 2}
variable "worker_mem" {default = 2048}
variable "worker_gateway" {default = "192.168.8.100"}
variable "worker_netmask" {default = "24"}
##########################____________________________________________________________________
#### Networks IP Range ###
##########################
variable "man_ip_range" {default = "192.168.8.15"} # manager IP range
variable "work_ip_range" {default = "192.168.8.16"} # worker IP range