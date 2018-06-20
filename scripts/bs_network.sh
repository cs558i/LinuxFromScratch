#!/bin/bash
#
# Cross compiler and Linux generation scripts
# (c)2014-2018 Jean-François DEL NERO
#
# Network support
#

source ${BASE_DIR}/scripts/unpack.sh || exit 1

source ${BASE_DIR}/configs/${TARGET_NAME}/config.sh || exit 1

echo "***********"
echo "* Network *"
echo "***********"

####################################################################
# LIBMNL (iptables)
####################################################################

CUR_PACKAGE=${SRC_PACKAGE_LIBMNL:-"UNDEF"}
CUR_PACKAGE="${CUR_PACKAGE##*/}"
if [ "$CUR_PACKAGE" != "UNDEF" ]
then
(
	if [ ! -f ${BASE_DIR}/build/${TARGET_NAME}/${CUR_PACKAGE}_DONE ]
	then
	(
		unpack ${CUR_PACKAGE} ""

		cd ${BASE_DIR}/build/$TARGET_NAME || exit 1
		mkdir libmnl
		cd libmnl || exit 1

		${BASE_DIR}/sources/${TARGET_NAME}/${TMP_ARCHIVE_FOLDER}/configure \
				--prefix="${TARGET_ROOTFS}" \
 				--build=$MACHTYPE \
				--host=$TGT_MACH \
				--target=$TGT_MACH || exit 1

		make ${NBCORE}         || exit 1
		make ${NBCORE} install || exit 1

		echo "" > ${BASE_DIR}/build/${TARGET_NAME}/${CUR_PACKAGE}_DONE

	) || exit 1
	fi
) || exit 1
fi

####################################################################
# LIBNFTNL (iptables)
####################################################################

CUR_PACKAGE=${SRC_PACKAGE_LIBNFTNL:-"UNDEF"}
CUR_PACKAGE="${CUR_PACKAGE##*/}"
if [ "$CUR_PACKAGE" != "UNDEF" ]
then
(
	if [ ! -f ${BASE_DIR}/build/${TARGET_NAME}/${CUR_PACKAGE}_DONE ]
	then
	(
		unpack ${CUR_PACKAGE} ""

		cd ${BASE_DIR}/build/$TARGET_NAME || exit 1
		mkdir libnftnl
		cd libnftnl || exit 1

		export LIBMNL_LIBS="-L${TARGET_ROOTFS}/lib/libmnl.so"
		export LIBMNL_CFLAGS="-I${TARGET_ROOTFS}/include"

		${BASE_DIR}/sources/${TARGET_NAME}/${TMP_ARCHIVE_FOLDER}/configure \
				--prefix="${TARGET_ROOTFS}" \
				--build=$MACHTYPE \
				--host=$TGT_MACH \
				--target=$TGT_MACH || exit 1

		make ${NBCORE}         || exit 1
		make ${NBCORE} install || exit 1

		echo "" > ${BASE_DIR}/build/${TARGET_NAME}/${CUR_PACKAGE}_DONE

	) || exit 1
	fi
) || exit 1
fi

####################################################################
# Iptables
####################################################################

CUR_PACKAGE=${SRC_PACKAGE_IPTABLES:-"UNDEF"}
CUR_PACKAGE="${CUR_PACKAGE##*/}"
if [ "$CUR_PACKAGE" != "UNDEF" ]
then
(
	if [ ! -f ${BASE_DIR}/build/${TARGET_NAME}/${CUR_PACKAGE}_DONE ]
	then
	(
		unpack ${CUR_PACKAGE} ""

		cd ${BASE_DIR}/build/$TARGET_NAME || exit 1
		mkdir iptables
		cd iptables || exit 1

		${BASE_DIR}/sources/${TARGET_NAME}/${TMP_ARCHIVE_FOLDER}/configure \
				--prefix="${TARGET_ROOTFS}" \
				--build=$MACHTYPE \
				--host=$TGT_MACH \
				--target=$TGT_MACH \
				--with-kernel=${BASE_DIR}/linux-4.7.5 \
				CFLAGS=-DPATH_MAX=4096 \
				LDFLAGS="${TARGET_ROOTFS}/lib/libmnl.so  ${TARGET_ROOTFS}/lib/libnftnl.so"  || exit 1

		make ${NBCORE}  || exit 1
		make ${NBCORE} install || exit 1

		echo "" > ${BASE_DIR}/build/${TARGET_NAME}/${CUR_PACKAGE}_DONE

	) || exit 1
	fi
) || exit 1
fi

####################################################################
# ntp client
####################################################################

CUR_PACKAGE=${SRC_PACKAGE_NTP:-"UNDEF"}
CUR_PACKAGE="${CUR_PACKAGE##*/}"
if [ "$CUR_PACKAGE" != "UNDEF" ]
then
(
	if [ ! -f ${BASE_DIR}/build/${TARGET_NAME}/${CUR_PACKAGE}_DONE ]
	then
	(
		unpack ${CUR_PACKAGE} ""

		cd ${BASE_DIR}/sources/${TARGET_NAME}/${TMP_ARCHIVE_FOLDER} || exit 1

		cd ${BASE_DIR}/build/${TARGET_NAME} || exit 1
		mkdir ntp
		cd ntp || exit 1

		${BASE_DIR}/sources/${TARGET_NAME}/${TMP_ARCHIVE_FOLDER}/configure \
				--prefix="${TARGET_ROOTFS}" \
				--build=$MACHTYPE \
				--host=$TGT_MACH \
				--target=$TGT_MACH \
				CFLAGS="-DMAX_PATH=4096 -DMB_LEN_MAX=16"\
				--with-yielding-select=yes || exit 1

		make ${NBCORE}         || exit 1
		make ${NBCORE} install || exit 1

		echo "" > ${BASE_DIR}/build/${TARGET_NAME}/${CUR_PACKAGE}_DONE

	) || exit 1
	fi
) || exit 1
fi

####################################################################
# dhcp server
####################################################################
CUR_PACKAGE=${SRC_PACKAGE_DHCPSERVER:-"UNDEF"}
CUR_PACKAGE="${CUR_PACKAGE##*/}"
if [ "$CUR_PACKAGE" != "UNDEF" ]
then
(
	if [ ! -f ${BASE_DIR}/build/${TARGET_NAME}/${CUR_PACKAGE}_DONE ]
	then
	(
		unpack ${CUR_PACKAGE} ""

		cd ${BASE_DIR}/sources/${TARGET_NAME}/${TMP_ARCHIVE_FOLDER} || exit 1

		export CROSS=${TGT_MACH}
		export CC=${TGT_MACH}-gcc
		export LD=${TGT_MACH}-ld
		export AS=${TGT_MACH}-as
		export AR=${TGT_MACH}-ar
		export TARGET_DIR=${TARGET_ROOTFS}
		export PREFIX=${TARGET_ROOTFS}

		${BASE_DIR}/sources/${TARGET_NAME}/${TMP_ARCHIVE_FOLDER}/configure \
				--prefix= \
				--sysconfdir=${TARGET_ROOTFS}/etc/dhcp \
				--localstatedir=/var \
				--with-srv-lease-file=/var/db/dhcpd.leases \
				--with-srv6-lease-file=/var/db/dhcpd6.leases \
				--with-cli-lease-file=/var/db/dhclient.leases \
				--with-cli6-lease-file=/var/db/dhclient6.leases \
				--host=$TGT_MACH \
				--cache-file=config.cache \
				BUILD_CC=gcc \
				--with-randomdev=no || exit 1

		make -j1         || exit 1
		make -j1 install DESTDIR=${TARGET_ROOTFS} || exit 1

		touch ${TARGET_ROOTFS}/var/db/dhcpd.leases

		echo "" > ${BASE_DIR}/build/${TARGET_NAME}/${CUR_PACKAGE}_DONE

	) || exit 1
	fi
) || exit 1
fi

####################################################################
#              ----------- Wifi Stack -----------
####################################################################

####################################################################
# Wireless tools
####################################################################

CUR_PACKAGE=${SRC_PACKAGE_WIRELESSTOOLS:-"UNDEF"}
CUR_PACKAGE="${CUR_PACKAGE##*/}"
if [ "$CUR_PACKAGE" != "UNDEF" ]
then
(
	if [ ! -f ${BASE_DIR}/build/${TARGET_NAME}/${CUR_PACKAGE}_DONE ]
	then
	(
		unpack ${CUR_PACKAGE} ""

		cd ${BASE_DIR}/sources/${TARGET_NAME}/${TMP_ARCHIVE_FOLDER} || exit 1

		export CROSS=${TGT_MACH}
		export CC=${TGT_MACH}-gcc
		export LD=${TGT_MACH}-ld
		export AS=${TGT_MACH}-as
		export AR=${TGT_MACH}-ar
		export TARGET_DIR=${TARGET_ROOTFS}
		export PREFIX=${TARGET_ROOTFS}

		make ${NBCORE} CC=${LFS_TGT}-gcc         || exit 1
		make ${NBCORE} install CC=${LFS_TGT}-gcc || exit 1

		echo "" > ${BASE_DIR}/build/${TARGET_NAME}/${CUR_PACKAGE}_DONE

	) || exit 1
	fi
) || exit 1
fi

####################################################################
# LIBNL 3
####################################################################

CUR_PACKAGE=${SRC_PACKAGE_LIBNL3:-"UNDEF"}
CUR_PACKAGE="${CUR_PACKAGE##*/}"
if [ "$CUR_PACKAGE" != "UNDEF" ]
then
(
	if [ ! -f ${BASE_DIR}/build/${TARGET_NAME}/${CUR_PACKAGE}_DONE ]
	then
	(
		unpack ${CUR_PACKAGE} ""

		cd ${BASE_DIR}/sources/${TARGET_NAME}/${TMP_ARCHIVE_FOLDER} || exit 1

		${BASE_DIR}/sources/${TARGET_NAME}/${TMP_ARCHIVE_FOLDER}/configure \
				--prefix="${TARGET_ROOTFS}" \
				--host=$TGT_MACH \
				CFLAGS="-DNAME_MAX=255"\
				|| exit 1


		make ${NBCORE}           || exit 1
		make ${NBCORE} install   || exit 1

		cd include     || exit 1
		make ${NBCORE} install   || exit 1

		echo "" > ${BASE_DIR}/build/${TARGET_NAME}/${CUR_PACKAGE}_DONE

	) || exit 1
	fi
) || exit 1
fi

####################################################################
# LIBNL 1
####################################################################

CUR_PACKAGE=${SRC_PACKAGE_LIBNL1:-"UNDEF"}
CUR_PACKAGE="${CUR_PACKAGE##*/}"
if [ "$CUR_PACKAGE" != "UNDEF" ]
then
(
	if [ ! -f ${BASE_DIR}/build/${TARGET_NAME}/${CUR_PACKAGE}_DONE ]
	then
	(
		unpack ${CUR_PACKAGE} ""

		cd ${BASE_DIR}/sources/${TARGET_NAME}/${TMP_ARCHIVE_FOLDER} || exit 1

		${BASE_DIR}/sources/${TARGET_NAME}/${TMP_ARCHIVE_FOLDER}/configure \
				--prefix="${TARGET_ROOTFS}" \
				--host=$TGT_MACH \
				CFLAGS="-DNAME_MAX=255"\
				|| exit 1

		make ${NBCORE}           || exit 1
		make ${NBCORE} install   || exit 1

		echo "" > ${BASE_DIR}/build/${TARGET_NAME}/${CUR_PACKAGE}_DONE

	) || exit 1
	fi
) || exit 1
fi

####################################################################
# IW
####################################################################

CUR_PACKAGE=${SRC_PACKAGE_IW:-"UNDEF"}
CUR_PACKAGE="${CUR_PACKAGE##*/}"
if [ "$CUR_PACKAGE" != "UNDEF" ]
then
(
	if [ ! -f ${BASE_DIR}/build/${TARGET_NAME}/${CUR_PACKAGE}_DONE ]
	then
	(
		unpack ${CUR_PACKAGE} ""

		cd ${BASE_DIR}/sources/${TARGET_NAME}/${TMP_ARCHIVE_FOLDER} || exit 1

		make ${NBCORE} CC=${TGT_MACH}-gcc                      || exit 1
		cp iw ${TARGET_ROOTFS}/sbin/                || exit 1

		echo "" > ${BASE_DIR}/build/${TARGET_NAME}/${CUR_PACKAGE}_DONE

	) || exit 1
	fi
) || exit 1
fi

####################################################################
# WPA Supplicant
####################################################################

CUR_PACKAGE=${SRC_PACKAGE_WPASUPPLICANT:-"UNDEF"}
CUR_PACKAGE="${CUR_PACKAGE##*/}"
if [ "$CUR_PACKAGE" != "UNDEF" ]
then
(
	if [ ! -f ${BASE_DIR}/build/${TARGET_NAME}/${CUR_PACKAGE}_DONE ]
	then
	(
		unpack ${CUR_PACKAGE} ""

		cd ${BASE_DIR}/sources/${TARGET_NAME}/${TMP_ARCHIVE_FOLDER} || exit 1

		cd wpa_supplicant     || exit 1

		cp defconfig .config  || exit 1

		export LIBDIR=/lib/
		export INCDIR=/include/
		export BINDIR=/sbin/

		make ${NBCORE} CC=${TGT_MACH}-gcc LDFLAGS+=-ldl || exit 1
		make ${NBCORE} install DESTDIR=${TARGET_ROOTFS} || exit 1

		echo "" > ${BASE_DIR}/build/${TARGET_NAME}/${CUR_PACKAGE}_DONE

	) || exit 1
	fi
) || exit 1
fi

####################################################################
# Hostapd
####################################################################

CUR_PACKAGE=${SRC_PACKAGE_HOSTAPD:-"UNDEF"}
CUR_PACKAGE="${CUR_PACKAGE##*/}"
if [ "$CUR_PACKAGE" != "UNDEF" ]
then
(
	if [ ! -f ${BASE_DIR}/build/${TARGET_NAME}/${CUR_PACKAGE}_DONE ]
	then
	(
		unpack ${CUR_PACKAGE} ""

		cd ${BASE_DIR}/sources/${TARGET_NAME}/${TMP_ARCHIVE_FOLDER} || exit 1

		cd hostapd     || exit 1

		cp ${BASE_DIR}/configs/${TARGET_NAME}/hostapd_config .config || exit 1

		export LIBDIR=/lib/
		export INCDIR=/include/
		export BINDIR=/sbin/

		make ${NBCORE} CC=${TGT_MACH}-gcc LDFLAGS+=-ldl || exit 1
		make ${NBCORE} install DESTDIR=${TARGET_ROOTFS} || exit 1

		echo "" > ${BASE_DIR}/build/${TARGET_NAME}/${CUR_PACKAGE}_DONE

	) || exit 1
	fi
) || exit 1
fi

####################################################################
# RFKill
####################################################################

CUR_PACKAGE=${SRC_PACKAGE_RFKILL:-"UNDEF"}
CUR_PACKAGE="${CUR_PACKAGE##*/}"
if [ "$CUR_PACKAGE" != "UNDEF" ]
then
(
	if [ ! -f ${BASE_DIR}/build/${TARGET_NAME}/${CUR_PACKAGE}_DONE ]
	then
	(
		unpack ${CUR_PACKAGE} ""

		cd ${BASE_DIR}/sources/${TARGET_NAME}/${TMP_ARCHIVE_FOLDER} || exit 1

		make ${NBCORE} CC=${TGT_MACH}-gcc              || exit 1
		make ${NBCORE} install PREFIX=${TARGET_ROOTFS}

		echo "" > ${BASE_DIR}/build/${TARGET_NAME}/${CUR_PACKAGE}_DONE

	) || exit 1
	fi
) || exit 1
fi

