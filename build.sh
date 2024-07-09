#!/bin/bash

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"
KERNEL="$(rpm -q kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')"
KERNEL_SUFFIX=""

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
# rpm-ostree install screen

# this would install a package from rpmfusion
# rpm-ostree install vlc

#### Example for enabling a System Unit File

find /tmp/akmods-rpms/

sed -i '/^PRETTY_NAME/s/Kinoite/Beblito-TKG/' /usr/lib/os-release

rpm-ostree install dnf5 binutils lz4
dnf5 upgrade -y

rpm-ostree install \
    libva-nvidia-driver \
    mesa-vulkan-drivers.i686 \
    nvidia-driver \
    nvidia-driver-cuda \
    nvidia-driver-cuda-libs.i686 \
    nvidia-driver-libs.i686 \
    nvidia-driver-NvFBCOpenGL \
    nvidia-modprobe \
    nvidia-persistenced \
    nvidia-settings \
    /tmp/akmods-rpms/kmod-nvidia-*.rpm


QUALIFIED_KERNEL="$(rpm -qa | grep -P 'kernel-(|'"$KERNEL_SUFFIX"'-)(\d+\.\d+\.\d+)' | sed -E 's/kernel-(|'"$KERNEL_SUFFIX"'-)//')"
/usr/libexec/rpm-ostree/wrapped/dracut --strip --aggressive-strip --no-hostonly --kver "$QUALIFIED_KERNEL" --reproducible -v --add ostree -f "/lib/modules/$QUALIFIED_KERNEL/initramfs.img"
chmod 0600 "/lib/modules/$QUALIFIED_KERNEL/initramfs.img"

#rpm-ostree install \
#    akmods \
#    dnf \
#    mock

#    curl -L https://negativo17.org/repos/fedora-nvidia.repo -o /etc/yum.repos.d/fedora-nvidia.repo

#    rpm-ostree install \
#        nvidia-driver \
#        nvidia-driver-libs.i686 \
#        nvidia-settings

#cd /tmp

# Either successfully build and install the kernel modules, or fail early with debug output
#rpm -qa |grep nvidia
#KERNEL_VERSION="$(rpm -q kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')"
#NVIDIA_AKMOD_VERSION="$(basename "$(rpm -q "akmod-nvidia" --queryformat '%{VERSION}-%{RELEASE}')" ".fc${RELEASE%%.*}")"


#akmods --force --kernels "${KERNEL}" --kmod "nvidia"

#modinfo /usr/lib/modules/${KERNEL}/extra/nvidia/nvidia{,-drm,-modeset,-peermem,-uvm}.ko.xz > /dev/null || \
#(cat /var/cache/akmods/nvidia/${NVIDIA_AKMOD_VERSION}-for-${KERNEL}.failed.log && exit 1)

# create a directory for later copying of resulting nvidia specific artifacts
#mkdir -p /var/cache/rpms/kmods/nvidia
#mkdir -p /tmp/rpms/nvidia/
#mkdir -p /rpms

#cat <<EOF > /var/cache/rpms/kmods/nvidia/nvidia-vars
#KERNEL_VERSION=${KERNEL_VERSION}
#RELEASE=${RELEASE}
#NVIDIA_AKMOD_VERSION=${NVIDIA_AKMOD_VERSION}
#EOF

#cp -v /var/cache/akmods/nvidia/*.rpm \
#   /tmp/rpms/nvidia/

#cp -v /var/cache/akmods/nvidia/*.rpm \
#   /rpms

rpm -qa |grep nvidia-kmod

#    rpm-ostree install \
#        /tmp/rpms/nvidia/kmod-nvidia-*.rpm \
