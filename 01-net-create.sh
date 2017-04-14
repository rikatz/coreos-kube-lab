#!/bin/bash
## Script based on https://raw.githubusercontent.com/coreos/docs/master/os/deploy_coreos_libvirt.sh
if [ "$USER" != "root" ]; then
    echo "Script must run as root user" && exit 1
fi

virsh net-define configs/net-coreos.xml
virsh net-autostart coreos
virsh net-start coreos