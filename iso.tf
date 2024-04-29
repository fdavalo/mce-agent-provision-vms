resource "vsphere_file" "ubuntu_vmdk_upload" {
  datacenter         = "dc-01"
  datastore          = "datastore-01"
  source_file        = "/my/src/path/custom_ubuntu.vmdk"
  destination_file   = "/my/dst/path/custom_ubuntu.vmdk"
  create_directories = true
}
