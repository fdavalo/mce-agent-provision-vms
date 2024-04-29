provider "vsphere" {
  # if you have a self-signed cert
  allow_unverified_ssl = true
}

variable "instance_name" {
 type = string
 default = "ocp"
 description = "instance name"
}

resource "vsphere_file" "iso_upload" {
  datacenter         = "HIT_RedHat"
  datastore          = "VV.HIT-RedHat"
  source_file        = "/my/src/path/custom_ubuntu.vmdk"
  destination_file   = "/ISOs/hcp02.iso"
  create_directories = false
}

}
