##############################################################################################################################################
#### vSphere Provider and login ##############################################################################################################
##############################################################################################################################################
provider "vsphere" {
  user           = "vCenter User Name"
  password       = "vCenter Password"
  vsphere_server = "vCenter Server FQDN"

  # if you have a self-signed cert
  allow_unverified_ssl = true
}


##############################################################################################################################################
#### Data for vSphere Resources ##############################################################################################################
##############################################################################################################################################
data "vsphere_datacenter" "dc" {
  name = "BenNet" ## VMware Data Center for Resources to reside in 
}
#--------------------
data "vsphere_datastore" "datastore" {
  name          = "BenNetESXI Local Storage M2 1TB" ## VMware Data Store for Resources to reside in 
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}
#--------------------
data "vsphere_resource_pool" "pool" {
  name          = "BenNet-DEV" ## VMware Resource Pool for Resources to reside in 
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}
#--------------------
data "vsphere_network" "network" {
  name          = "BenNetTest_Network" ## VMware Network for Resources to reside on
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}


##########################################################################################################################################################
#### Docker Swarm Master Manager Informtion ##############################################################################################################
##########################################################################################################################################################

#### IP information to for Master Manager 
variable "template_ip_address" {default = "192.168.8.140"} ### This must be the address you initilized the Swarm from 
#--------------------
#### Name Information
variable "template_vm_name" {default = "BenNetAWX"} ### VM and VMDK name
#--------------------
variable "template_host_name" {default = "bennetawx"} ### Machine host name 

####------------------------------------------------
#### Template Information 
data "vsphere_virtual_machine" "vmware-template" {
  name          = "BenNetAWX-Template"  # Name of VMware template to use
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}
####------------------------------------------------
#### Resource Information 
variable "template_cpu" {default = 4}
#--------------------
variable "template_mem" {default = 4096}
#--------------------
variable "template_netmask" {default = "24"}


#######################################################################################################################################
#### Global Networks Info #############################################################################################################
#######################################################################################################################################
variable "ipv4_netmask" {default = 24} # manager IP range
#--------------------
variable "default_gateway" {default = "192.168.8.100"} # defualt gateway
#--------------------
variable "dns_server" {default = "192.168.10.115"} # DNS server
#--------------------
variable "domain" {default = "bennettest.com"} # Domain 


####################################################################################################################################
#### SSH Creditials   ##############################################################################################################
####################################################################################################################################

#### Template SSH Password
variable "ssh-user" {default = "SSH User Name"}
#--------------------
variable "ssh-password" {default = "SSH Password"}
#--------------------
variable "sudo-password" {default = "Sudo Password"}