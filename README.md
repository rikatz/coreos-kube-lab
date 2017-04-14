# Introduction

This project intends to create a quick CoreOS + Kubernetes environment using KVM and Libvirt

# Configuration

First we need to configure the files inside the 'configs' directory:

## env

Configure the following directives:

* CHANNEL - May contain stable, alpha or beta (CoreOS CL Channels)
* RELEASE - Must contain the exactly version of CoreOS that will be used. 

## net-coreos.xml

This config file is used to create the CoreOS Network that will be used by the VMs, instead of using the 'default' network.

## vms

This file contains the Virtual Machines that will be created. The header of the file contains it structure, but it's as the following:

``Name,MacAddress,IP,userdata,cpus,memory``
* Name - The name of the VM, will be used in VM Name, the DHCP reservation configuration and so.
* MacAddress - The Mac Address the machine will use. May be any Mac Address, and can be generated [here](http://www.miniwebtool.com/mac-address-generator/). Must be like AA:BB:CC:DD:EE:FF
* IpAddress - The IP Address of the VM. This will be inserted in DHCP Reservation and must be in the same subnet defined in 'net-coreos.xml' file
* Userdata - The location of userdata that will be used to configure CoreOS Cloud Config as described [here](https://coreos.com/os/docs/latest/cloud-config.html)
* CPUs - Number of CPUs of the VM
* Memory - MBs of RAM

Example of lines: 
```
master,00:50:56:B5:C0:11,192.168.111.10,master.yaml,1,1024
node1,00:50:56:48:0A:12,192.168.111.11,node1.yaml,1,1024
node2,00:50:56:E1:F2:13,192.168.111.12,node2.yaml,1,1024
```

# Usage

The scripts must be run in the sorted order. First we must run the 00-download-img.sh to download the image that will be used in the installation.

Next we must run 01-net-create.sh to create the coreos network, according to net-coreos.xml file.

Last, for each machine we want to create we must run the 02-create-vm.sh as the following:

``02-create-vm.sh CONFIGFILE VMNAME``.

So, to create *master* and *node1* machines, we must run the command for each of them, as the following:

```
02-create-vm.sh configs/vms master
02-create-vm.sh configs/vms node1
```