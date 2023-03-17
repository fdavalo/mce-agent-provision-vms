provider "vsphere" {
  # if you have a self-signed cert
  allow_unverified_ssl = true
}

variable "instance_name" {
 type = string
 default = "ocp"
 description = "instance name"
}

data "vsphere_datacenter" "dc" {
  name = "HIT_RedHat"
}

data "vsphere_datastore" "datastore" {
  name          = "VV.HIT-RedHat"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_compute_cluster" "cluster" {
  name          = "HIT_RedHat"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "network" {
  name          = "Openshift"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_virtual_machine" "template" {
  name          = "ocp-template-ocp1"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
  folder        = "OCP-NODES"
}

resource "random_string" "suffix" {
  length = 8 
  lower  = true
  special = false
}

resource "vsphere_virtual_machine" "ocp_node" {
  #####
  # VM Specifications
  ####
  resource_pool_id = "${data.vsphere_compute_cluster.cluster.resource_pool_id}" 

  name      = "${lower(var.instance_name)}-node-${lower(random_string.suffix.result)}"
  folder    = "OCP-NODES"
  num_cpus  = "${data.vsphere_virtual_machine.template.num_cpus}"
  memory    = "${data.vsphere_virtual_machine.template.memory}"

  scsi_controller_count = 1

  ####
  # Disk specifications
  ####
  datastore_id  = "${data.vsphere_datastore.datastore.id}"
  guest_id      = "${data.vsphere_virtual_machine.template.guest_id}"
  scsi_type     = "${data.vsphere_virtual_machine.template.scsi_type}"

  disk {
    label            = ""
    size             = "${data.vsphere_virtual_machine.template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
    keep_on_remove   = false 
    unit_number      = 0
  }

  cdrom {
     datastore_id = "${data.vsphere_datastore.datastore.id}"
     path         = "ISOs/ocp1-baremetal-discovery.iso"
  }

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"
  }
}
