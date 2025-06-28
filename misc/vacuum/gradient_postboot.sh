#!/bin/sh

set -eu
set -o pipefail

exec >> /dev/kmsg
exec 2>&1

echo "Initializing gradient_postboot..." 

rm -f /tmp/.profile
ln -s /data/gradient_profile.sh /tmp/.profile

echo "Linked gradient_profile to temporary folder." 

mkdir -p /data/overlay
mkdir -p /data/overlay/work
mkdir -p /data/overlay/upper
mkdir -p /data/overlay/root

echo "Ensured gradient overlay folders exist..."

mount -t overlay overlay -o lowerdir=/,upperdir=/data/overlay/upper,workdir=/data/overlay/work /data/overlay/root

echo "Mounted gradient overlay, binding other mounts..." 

mount --bind /mnt /data/overlay/root/mnt
mount --bind /mnt/misc /data/overlay/root/mnt/misc
mount --bind /mnt/private /data/overlay/root/mnt/private
mount --bind /dev /data/overlay/root/dev
mount --bind /dev/shm /data/overlay/root/dev/shm
mount --bind /tmp /data/overlay/root/tmp
mount --bind /data /data/overlay/root/data
mount --bind /proc /data/overlay/root/proc
mount --bind /sys /data/overlay/root/sys

echo "Other mounts bound to gradient overlay folders, running gradient provisioning script..."

/bin/sh -c 'chroot /data/overlay/root /data/gradient_provision.sh' &