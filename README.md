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
   
   The Tekton pipeline consists of 3 steps :

* Clone this git repository 

* Use terraform to create the Virtual Machine 

* A bash script will fetch Virtual Machine name and IP to update the Agent (approved=true, hostname=vm name)

[![Pipeline to create the virtual machine](https://github.com/fdavalo/mce-agent-provision-vms/blob/main/pipeline-vsphere.png?raw=true)](pipeline-vsphere.png)

## See the new Host available on the Infrastructure Environment
   
[![See the Host](https://github.com/fdavalo/mce-agent-provision-vms/blob/main/agent-vsphere.png?raw=true)](agent-vsphere.png)

