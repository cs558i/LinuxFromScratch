#!/bin/bash
#
# Cross compiler and Linux generation scripts
# (c)2014-2021 Jean-François DEL NERO
#
# Raspberry Pi Zero W target post install process
#

source ${TARGET_CONFIG}/config.sh || exit 1

mkdir ${TARGET_HOME}/output_objects

###############################################################################
# Create SD Card image

dd if=/dev/zero of=${TARGET_HOME}/output_objects/sdcard.img iflag=fullblock bs=1M count=1024 && sync
sudo losetup loop0 --sector-size 512  ${TARGET_HOME}/output_objects/sdcard.img || exit 1
sudo sfdisk -f /dev/loop0 < ${TARGET_CONFIG}/sfdisk.txt || exit 1
sudo losetup -d /dev/loop0

fdisk -l ${TARGET_HOME}/output_objects/sdcard.img

###############################################################################
# Format the partitions

sudo losetup --show --sector-size 512 -f -P ${TARGET_HOME}/output_objects/sdcard.img
# Boot partion -> FAT
sudo mkfs.vfat /dev/loop0p1

# System partition
sudo mkfs.ext2 /dev/loop0p2

sudo losetup -d /dev/loop0

###############################################################################

echo "Copy boot files to the file image ..."
mkdir ${TARGET_HOME}/output_objects/tmp_mount_point

sudo losetup --show --sector-size 512 -f -P ${TARGET_HOME}/output_objects/sdcard.img
sudo mount /dev/loop0p1 ${TARGET_HOME}/output_objects/tmp_mount_point

# Boot loader blob
rm -rf ${TARGET_HOME}/output_objects/RPIZw_bootpart
unzip ${TARGET_HOME}/config/boot_part/RPIZw_bootpart.zip -d ${TARGET_HOME}/output_objects/
sudo cp -a ${TARGET_HOME}/output_objects/RPIZw_bootpart/* ${TARGET_HOME}/output_objects/tmp_mount_point

# Kernel
sudo cp ${TARGET_ROOTFS_MIRROR}/boot/Image ${TARGET_HOME}/output_objects/tmp_mount_point/kernel.img
sudo cp -a ${TARGET_ROOTFS_MIRROR}/boot/dts/overlays ${TARGET_HOME}/output_objects/tmp_mount_point/
sudo umount ${TARGET_HOME}/output_objects/tmp_mount_point

# Fix/force the disk partitions uuid -> Must be equal to the cmdline.txt value
sudo fdisk /dev/loop0 <<EOF > /dev/null
p
x
i
0x80e567d8
r
p
w
EOF

sudo losetup -d /dev/loop0

sync

###############################################################################

echo "Copy rootfs to the file image ..."

sudo losetup --show --sector-size 512 -f -P ${TARGET_HOME}/output_objects/sdcard.img
sudo mount /dev/loop0p2 ${TARGET_HOME}/output_objects/tmp_mount_point

sudo cp -av ${TARGET_ROOTFS_MIRROR}/* ${TARGET_HOME}/output_objects/tmp_mount_point/.

# Add here the customizations

#sudo cp -av ${TARGET_HOME}/output_objects/a_new_program  ${TARGET_HOME}/output_objects/tmp_mount_point/usr/sbin || exit 1

###############################################################################
# owner / group / right accesses fix

sudo chown 1001 ${TARGET_HOME}/output_objects/tmp_mount_point/ramdisk
sudo chgrp 1001 ${TARGET_HOME}/output_objects/tmp_mount_point/ramdisk
sudo chmod o+wr ${TARGET_HOME}/output_objects/tmp_mount_point/ramdisk

sudo chown -R root ${TARGET_HOME}/output_objects/tmp_mount_point/*
sudo chgrp -R root ${TARGET_HOME}/output_objects/tmp_mount_point/*

sudo chmod ugo-w   ${TARGET_HOME}/output_objects/tmp_mount_point/home
sudo chmod +x      ${TARGET_HOME}/output_objects/tmp_mount_point/etc/*.sh
sudo chmod +x      ${TARGET_HOME}/output_objects/tmp_mount_point/etc/rcS.d/*.sh
sudo chmod go-w    ${TARGET_HOME}/output_objects/tmp_mount_point/etc/*.sh
sudo chmod go-w    ${TARGET_HOME}/output_objects/tmp_mount_point/etc/rcS.d/*.sh
sudo chmod go-w    ${TARGET_HOME}/output_objects/tmp_mount_point/etc/*
sudo chmod ugo-rwx ${TARGET_HOME}/output_objects/tmp_mount_point/etc/passwd
sudo chmod u+rw    ${TARGET_HOME}/output_objects/tmp_mount_point/etc/passwd
sudo chmod go+r    ${TARGET_HOME}/output_objects/tmp_mount_point/etc/passwd

sudo umount ${TARGET_HOME}/output_objects/tmp_mount_point
sudo losetup -d /dev/loop0

###############################################################################
