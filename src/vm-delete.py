#!/usr/bin/env python

"""
* *******************************************************
* Copyright (c) VMware, Inc. 2017, 2018. All Rights Reserved.
* SPDX-License-Identifier: MIT
* *******************************************************
*
* DISCLAIMER. THIS PROGRAM IS PROVIDED TO YOU "AS IS" WITHOUT
* WARRANTIES OR CONDITIONS OF ANY KIND, WHETHER ORAL OR WRITTEN,
* EXPRESS OR IMPLIED. THE AUTHOR SPECIFICALLY DISCLAIMS ANY IMPLIED
* WARRANTIES OR CONDITIONS OF MERCHANTABILITY, SATISFACTORY QUALITY,
* NON-INFRINGEMENT AND FITNESS FOR A PARTICULAR PURPOSE.
"""

__author__ = 'VMware, Inc.'
__vcenter_version__ = '6.5+'

from vmware.vapi.vsphere.client import create_vsphere_client

from com.vmware.vcenter.vm_client import Power
from com.vmware.vcenter_client import VM

import os
import requests

class DeleteVM(object):
    """
    Demonstrates Deleting User specified Virtual Machine (VM)
    Sample Prerequisites:
    vCenter/ESX
    """

    def __init__(self):
        self.vm_name = os.getenv('VM_NAME')

        session = requests.session()

        # Disable cert verification for demo purpose. 
        # This is not recommended in a production environment.
        session.verify = False

        # Connect to vSphere client
        self.client = create_vsphere_client(server=os.getenv('VSPHERE_SERVER'),
                                            username=os.getenv('VSPHERE_USER'),
                                            password=os.getenv('VSPHERE_PASSWORD'),
                                            session=session)



    def get_vm(self):
        """
        Return the identifier of a vm
        Note: The method assumes that there is only one vm with the mentioned name.
        """
        names = set([self.vm_name])
        vms = self.client.vcenter.VM.list(VM.FilterSpec(names=names))

        if len(vms) == 0:
            print("VM with name ({}) not found".format(self.vm_name))
            return None

        vm = vms[0].vm
        print("Found VM '{}' ({})".format(self.vm_name, vm))
        return vm


    def run(self):
        """
        Delete User specified VM from Server
        """
        vm = self.get_vm()
        if vm is not None:
            print("Deleting VM -- '{}-({})')".format(self.vm_name, vm))
            state = self.client.vcenter.vm.Power.get(vm)
            if state == Power.Info(state=Power.State.POWERED_ON):
                self.client.vcenter.vm.Power.stop(vm)
            elif state == Power.Info(state=Power.State.SUSPENDED):
                self.client.vcenter.vm.Power.start(vm)
                self.client.vcenter.vm.Power.stop(vm)
            self.client.vcenter.VM.delete(vm)
            print("Deleted VM -- '{}-({})".format(self.vm_name, vm))


def main():
    delete_vm = DeleteVM()
    delete_vm.run()


if __name__ == '__main__':
    main()
