#!/bin/bash
## Script based on https://raw.githubusercontent.com/coreos/docs/master/os/deploy_coreos_libvirt.sh
# Usage: 01-create-vm.sh vmname userdatalocation num_of_cpus mb_of_memory


if [ "$USER" != "root" ]; then
    echo "Script must run as root user" && exit 1
fi

source configs/env

CONFIG=$1
SERVIDOR=$2


error() {
    echo $1
    exit 1
}

addNetReservation() {
    echo "Creating Network Reservation for $COREOS_HOSTNAME: $IPADDRESS through MAC ADDRESS $MACADDRESS"
    virsh net-update coreos add ip-dhcp-host \
        "<host mac='$MACADDRESS' name='$COREOS_HOSTNAME' ip='$IPADDRESS' />" \
        --live --config
}

create() {
    CFGSERVER=$(grep -E "^$2," $1 |head -n 1)
    COREOS_HOSTNAME=$(echo $CFGSERVER |cut -f 1 -d ',')
    MACADDRESS=$(echo $CFGSERVER |cut -f 2 -d ',')
    IPADDRESS=$(echo $CFGSERVER |cut -f 3 -d ',')
    USERDATA=$(echo $CFGSERVER |cut -f 4 -d ',')
    CPUs=$(echo $CFGSERVER |cut -f 5 -d ',')
    RAM=$(echo $CFGSERVER |cut -f 6 -d ',')
    echo "Creating server $COREOS_HOSTNAME with $CPUs CPUs, ${RAM}mb of memory, IP $IPADDRESS and userdata $USERDATA"
    # This is the step necessary for user_data in KVM/Libvirt environments
    if [ ! -d $LIBVIRT_PATH/$COREOS_HOSTNAME/openstack/latest ]; then
        mkdir -p $LIBVIRT_PATH/$COREOS_HOSTNAME/openstack/latest || (echo "Can not create $LIBVIRT_PATH/$COREOS_HOSTNAME/openstack/latest directory" && exit 1)
    fi
    rm -f $LIBVIRT_PATH/$COREOS_HOSTNAME/openstack/latest/user_data
    cp userdatas/$USERDATA $LIBVIRT_PATH/$COREOS_HOSTNAME/openstack/latest/user_data

    # This is the step that creates a 'linked disk' to the original CoreOS qcow file
    if [ ! -f $LIBVIRT_PATH/$COREOS_HOSTNAME.qcow2 ]; then
        qemu-img create -f qcow2 -b $LIBVIRT_PATH/$IMG_NAME $LIBVIRT_PATH/$COREOS_HOSTNAME.qcow2
    fi

    # Now we create the machine :)

    addNetReservation

    virt-install --connect qemu:///system \
        --import \
        --name $COREOS_HOSTNAME \
        --ram $RAM \
        --vcpus $CPUs \
        --os-type=linux \
        --os-variant=virtio26 \
        --disk path=$LIBVIRT_PATH/$COREOS_HOSTNAME.qcow2,format=qcow2,bus=virtio \
        --filesystem $LIBVIRT_PATH/$COREOS_HOSTNAME/,config-2,type=mount,mode=squash \
        --network network=coreos,mac=$MACADDRESS \
        --vnc \
        --noautoconsole || error "Failed to create the virtual machine"
}

# Verify the prereqs
which qemu-img > /dev/null || error "qemu-img not found, please install qemu-utils"
which virt-install > /dev/null || error "virt-install not found, please install virtinst and virt-manager packages"
modinfo kvm > /dev/null || error "KVM not found, please install KVM"
which libvirtd > /dev/null || error "Libvirt not found, please install the package libvirt-bin"
which kvm > /dev/null|| error "Qemu-kvm not found, please install qemu-kvm"

create "$CONFIG" "$SERVIDOR"
