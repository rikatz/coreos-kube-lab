#!/bin/bash
## Script based on https://raw.githubusercontent.com/coreos/docs/master/os/deploy_coreos_libvirt.sh
if [ "$USER" != "root" ]; then
    echo "Script must run as root user" && exit 1
fi

source configs/env
if [ ! -d $LIBVIRT_PATH ]; then
        mkdir -p $LIBVIRT_PATH || (echo "Can not create $LIBVIRT_PATH directory" && exit 1)
fi

if [ ! -f $LIBVIRT_PATH/$IMG_NAME ]; then
        echo "Image not found, downloading ..."
        wget https://${CHANNEL}.release.core-os.net/amd64-usr/${RELEASE}/coreos_production_qemu_image.img.bz2 -O - | bzcat > $LIBVIRT_PATH/$IMG_NAME || (rm -f $LIBVIRT_PATH/$IMG_NAME && echo "Failed to download image" && exit 1)
else 
        echo "Image exists in the Libvirt image directory, nothing to do"
fi