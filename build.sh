#!/bin/bash

set -ouex pipefail

#set -o errexit  # Exit immediately if a command exits with a non-zero status
#set -o nounset  # Treat unset variables as an error when substituting
#set -o pipefail # Prevents errors in a pipeline from being masked
#set -o xtrace   # Print commands and their arguments as they are executed

# Find RPM packages in the /tmp/akmods-rpms/ directory
find /tmp/akmods-rpms/

# Modify the PRETTY_NAME in the os-release file
sed -i '/^PRETTY_NAME/s/Kinoite/beblito-tkg/' /usr/lib/os-release

# Install necessary packages
rpm-ostree install dnf5 binutils lz4
dnf5 upgrade -y

# Install Nvidia drivers and related packages
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

# Extract and format the qualified kernel version
QUALIFIED_KERNEL="$(rpm -qa | grep -P 'kernel-(\d+\.\d+\.\d+)' | sed -E 's/kernel-//')"

# Generate initramfs image
/usr/libexec/rpm-ostree/wrapped/dracut --strip --aggressive-strip --no-hostonly --kver "$QUALIFIED_KERNEL" --reproducible -v --add ostree -f "/lib/modules/$QUALIFIED_KERNEL/initramfs.img"
chmod 0600 "/lib/modules/$QUALIFIED_KERNEL/initramfs.img"

# Check for installed Nvidia kernel module
rpm -qa | grep nvidia-kmod
