# Using agent mode for provisioning virtual machines with multi cluster engine

## Create an Infrastructure Environment (baremetal)

[![See the Host](https://github.com/fdavalo/mce-agent-provision-vms/blob/main/agent-vsphere.png?raw=true)](agent-vsphere.png)

## Upload on Vsphere the discovery ISO downloaded from the Infrastructure Environment

[![Upload ISO on vsphere](https://github.com/fdavalo/mce-agent-provision-vms/blob/main/vsphere-iso.png?raw=true)](vsphere-iso.png)

## Create a Virtual Machine on Vsphere to be used as template for nodes

   The virtual machine will not be started, only created to be cloned as template
   
[![Create a virtual machine on vsphere](https://github.com/fdavalo/mce-agent-provision-vms/blob/main/vsphere-vm-template.png?raw=true)](vsphere-vm-template.png)

## Clone the Virtual Machine as a template
   
[![Clone the virtual machine as a template on vsphere](https://github.com/fdavalo/mce-agent-provision-vms/blob/main/vsphere-template.png?raw=true)](vsphere-template.png)

## Use the Tekton Pipeline to create the Virtual Machine
   
   The Pipeline is started and asking for a Workspace (persistent volume to share files between tasks), choose a volume claim template

   The Tekton pipeline consists of 3 steps :

* Clone this git repository (fetch terraform template and bash scripts)

* Use terraform to create the Virtual Machine (random name is used, a cdrom is used to boot the discovery iso)

               resource "vsphere_virtual_machine" "ocp_node" {
                 #####
                 # VM Specifications
                 ####
                 resource_pool_id = "${data.vsphere_compute_cluster.cluster.resource_pool_id}" 

                 name      = "${lower(var.instance_name)}-node-${lower(random_string.suffix.result)}"
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

* A bash script will fetch Virtual Machine name and IP to update the Agent (approved=true, hostname=vm name)

[![Pipeline to create the virtual machine](https://github.com/fdavalo/mce-agent-provision-vms/blob/main/pipeline-vsphere.png?raw=true)](pipeline-vsphere.png)

## See the new Host available on the Infrastructure Environment
   
   You can now create clusters or scale clusters using those available nodes
   
[![See the Host](https://github.com/fdavalo/mce-agent-provision-vms/blob/main/agent-vsphere.png?raw=true)](agent-vsphere.png)

