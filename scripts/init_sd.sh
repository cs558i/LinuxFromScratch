#!/bin/bash
#
# Cross compiler and Linux generation scripts
# (c)2014-2018 Jean-François DEL NERO
#
# SD init (to rework...)
#

CROSS_BUILD_SIGN=${CROSS_BUILD_SIGN:-"UNDEF"}

if [ $CROSS_BUILD_SIGN != "CROSS_ENV_SET" ]; then

echo "*******************************"
echo "*    Environment not set !    *"
echo "*   Please call set_env.sh    *"
echo "*******************************"

exit 2

fi

source ${TARGET_CONFIG}/config.sh || exit 1

##########################################################################
# Duplicate root fs
##########################################################################

export TARGET_ROOTFS_MIRROR=${TARGET_HOME}/fs_mirror

rm -Rf ${TARGET_ROOTFS_MIRROR}

mkdir  ${TARGET_ROOTFS_MIRROR}
cd     ${TARGET_ROOTFS_MIRROR}

cp -av ${TARGET_ROOTFS}/* .

##########################################################################
# Strip the whole root fs !
##########################################################################

rm -R bin/ld bin/ld.bfd bin/as bin/objdump bin/strip bin/ar bin/ranlib bin/nm bin/readelf bin/omshell
rm -R man
rm -R ssl
rm -R share/man
rm -R share/doc
rm -R share/gtk-doc
rm -R share/locale/*
rm -R share/info/*
rm -R share/i18n
rm -R include
find ./lib -type f -name "*.la" -delete
find ./lib -type f -name "*.a" -delete
find ./lib64 -type f -name "*.la" -delete
find ./lib64 -type f -name "*.a" -delete
rm ./bin/smbd/*.old
rm ./bin/smbclient/*.old

find ./ -type f -print0  -print | xargs -0 ${TGT_MACH}-strip --strip-debug --strip-unneeded

find ./bin   -type f -exec ${TGT_MACH}-strip --strip-debug --strip-unneeded {} \;
find ./lib   -type f -exec ${TGT_MACH}-strip --strip-debug --strip-unneeded {} \;
find ./lib64 -type f -exec ${TGT_MACH}-strip --strip-debug --strip-unneeded {} \;
find ./sbin  -type f -exec ${TGT_MACH}-strip --strip-debug --strip-unneeded {} \;
find ./usr   -type f -exec ${TGT_MACH}-strip --strip-debug --strip-unneeded {} \;

# Fix buggy path...
gcc ${BASE_DIR}/scripts/fix_bin_paths.c -o ${BASE_DIR}/scripts/fix_bin_paths

find ./ -type f -exec ${BASE_DIR}/scripts/fix_bin_paths {} ${TARGET_ROOTFS} \;

##########################################################################
# Copy configs files and do some last fixes...
##########################################################################

chmod +x "./lib/libc.so" || exit 1
chmod +x "./lib/libpthread.so" || exit 1

cp -R ${BASE_DIR}/targets/common/config/rootfs_cfg/* ./
cp -R ${TARGET_CONFIG}/rootfs_cfg/* ./

chmod +x ./etc/init.d/rcS
chmod +x ./etc/init.d/rcS
chmod +x ./etc/init.d/rcS.d/*

chmod +x ./usr/share/udhcpc/*
chmod go-rxw ./etc/ssh/ssh_host_*

mkdir home/anonymous
mkdir home/root
mkdir ramdisk
mkdir mnt/tmp
mkdir usr/share/empty

##########################################################################
# Post process install...
##########################################################################

if [ -f ${TARGET_CONFIG}/install_post_process.sh ]
then
(
	echo Post install script available...
	${TARGET_CONFIG}/install_post_process.sh || exit 1
)
fi

##########################################################################
# Copy to Flash media !
##########################################################################

cd ..

if [ ! -f $1 ]; then
    echo "Copy to Flash media ..."

    sudo umount $1

    sudo mkfs.ext4 $1

    mkdir mount_point

    sudo mount $1 mount_point || exit 1

    cd mount_point

    sudo cp -av ${TARGET_ROOTFS_MIRROR}/* .

    sudo chown -R root *
    sudo chgrp -R root *

    sudo chmod ugo-w home
    sudo chmod +x etc/*.sh
    sudo chmod +x etc/rcS.d/*.sh	
    sudo chmod go-w etc/*.sh
    sudo chmod go-w etc/rcS.d/*.sh	
    sudo chmod go-w etc/*
    sudo chmod ugo-rwx etc/passwd
    sudo chmod u+rw etc/passwd
    sudo chmod go+r etc/passwd
	
    cd ..

    sudo umount $1
fi

echo  Done !
