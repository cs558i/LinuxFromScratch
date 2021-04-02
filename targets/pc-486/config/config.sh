#!/bin/bash
#
# Cross compiler and Linux generation scripts
# (c)2014-2021 Jean-François DEL NERO
#
# i486-pc setup
#

export KERNEL_ARCH=x86
export TGT_MACH=i486-linux
export SSL_ARCH=linux-generic32
export GCC_ADD_CONF=""

export KERNEL_IMAGE_TYPE=""

export DEBUG_SUPPORT="1"
export NETWORK_SUPPORT="1"
export TARGET_BUILD_SUPPORT="1"
export NETWORK_STATION_MODE="1"

#export WIRELESS_SUPPORT="1"
#export GFX_SUPPORT="1"
#export WAYLAND_SUPPORT="1"
#export AUDIO_SUPPORT="1"

source ${BASE_DIR}/targets/common/config/config.sh || exit 1

#export MESA_DRI_DRV="i915,i965,nouveau,radeon,r200,swrast"
#export MESA_GALLIUM_DRV="i915,nouveau,r600,svga,swrast"

#export DRM_SUPPORT="--enable-intel --enable-radeon --enable-amdgpu --enable-nouveau"

SRC_PACKAGE_GLIBC="@COMMON@""https://ftp.gnu.org/gnu/glibc/glibc-2.32.tar.xz"
SRC_PACKAGE_BUSYBOX="@COMMON@""https://busybox.net/downloads/busybox-1.32.1.tar.bz2"

SRC_PACKAGE_LIBPCIACCESS="https://www.x.org/archive/individual/lib/libpciaccess-0.14.tar.gz"

# Loader
SRC_PACKAGE_SYSLINUX="https://mirrors.edge.kernel.org/pub/linux/utils/boot/syslinux/Testing/6.04/syslinux-6.04-pre1.tar.gz"

# Kernel
SRC_PACKAGE_KERNEL="https://git.kernel.org/torvalds/t/linux-5.12-rc5.tar.gz"

SRC_PACKAGE_DIRECTFB=
SRC_PACKAGE_PYTHON=
SRC_PACKAGE_PERL=
SRC_PACKAGE_PERLCROSS=

SRC_PACKAGE_DDRESCUE="https://github.com/mruffalo/ddrescue/archive/refs/tags/v1.24.tar.gz"

