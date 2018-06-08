#!/bin/bash
#
# Cross compiler and Linux generation scripts
# (c)2014-2018 Jean-François DEL NERO
#
# Main entry script
#

CROSS_BUILD_SIGN=${CROSS_BUILD_SIGN:-"UNDEF"}

if [ $CROSS_BUILD_SIGN != "CROSS_ENV_SET" ]; then

echo "*******************************"
echo "*    Environment not set !    *"
echo "*   Please call set_env.sh    *"
echo "*******************************"

exit 2

fi

source ${BASE_DIR}/configs/common/config.sh || exit 1

source ${BASE_DIR}/configs/${TARGET_NAME}/config.sh || exit 1

stage_download="yes"
stage_sysbase="yes"
stage_libraries="yes"
stage_sysshell="yes"
stage_services="yes"
stage_debugdev="yes"
stage_graphicstack="yes"
stage_network="yes"
stage_miscellaneous="yes"

mkdir -p ${BASE_DIR}/download             || exit 1
mkdir -p ${BASE_DIR}/build                || exit 1
mkdir -p ${BASE_DIR}/build/$TARGET_NAME   || exit 1
mkdir -p ${BASE_DIR}/sources              || exit 1
mkdir -p ${BASE_DIR}/sources/$TARGET_NAME || exit 1
mkdir -p ${TARGET_ROOTFS}                  || exit 1

####################################################################
# Sources Download...
####################################################################
if [ $stage_download = "yes" ];
then
(
	./scripts/bs_download.sh
) || exit 1

fi

####################################################################
# Build root tree
####################################################################
(
	./scripts/bs_init_rootfs_tree.sh
)

####################################################################
# System Base (Crosscompiler + Glibc + C/C++ libs + kernel)
####################################################################
if [ $stage_sysbase = "yes" ];
then
(
	./scripts/bs_system_base.sh
) || exit 1
fi

####################################################################
# Librairies
####################################################################
if [ $stage_libraries = "yes" ];
then
(
	./scripts/bs_libraries.sh
) || exit 1
fi

####################################################################
# System shell
####################################################################
if [ $stage_sysshell = "yes" ];
then
(
	./scripts/bs_system_shell.sh
) || exit 1
fi

####################################################################
# System services
####################################################################
if [ $stage_services = "yes" ];
then
(
	./scripts/bs_services.sh
) || exit 1
fi

####################################################################
# Network support
####################################################################
if [ $stage_network = "yes" ];
then
(
	./scripts/bs_network.sh
) || exit 1
fi

####################################################################
# Graphic stack
####################################################################
if [ $stage_graphicstack = "yes" ];
then
(
	./scripts/bs_graphic_stack.sh
) || exit 1
fi

####################################################################
# Miscellaneous
####################################################################
if [ $stage_miscellaneous = "yes" ];
then
(
	./scripts/bs_misc.sh
) || exit 1
fi

####################################################################
# Debug & Dev tools
####################################################################
if [ $stage_debugdev = "yes" ];
then
(
	./scripts/bs_debug_dev.sh
) || exit 1
fi

(
	echo "************************************"
	echo "************************************"
	echo "**     System compilation ok !    **"
	echo "************************************"
	echo "************************************"
	date
)

