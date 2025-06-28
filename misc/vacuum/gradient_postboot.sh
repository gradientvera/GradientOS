#!/bin/sh

rm -f /tmp/.profile
ln -s /data/gradient_profile.sh /tmp/.profile

mkdir -p /data/overlay
mkdir -p /data/overlay/work
mkdir -p /data/overlay/upper
mkdir -p /data/overlay/root

mount -t overlay overlay -o lowerdir=/,upperdir=/data/overlay/upper,workdir=/data/overlay/work /data/overlay/root

mount --bind /mnt /data/overlay/root/mnt
mount --bind /mnt/misc /data/overlay/root/mnt/misc
mount --bind /mnt/private /data/overlay/root/mnt/private
mount --bind /dev /data/overlay/root/dev
mount --bind /dev/shm /data/overlay/root/dev/shm
mount --bind /tmp /data/overlay/root/tmp
mount --bind /data /data/overlay/root/data
mount --bind /proc /data/overlay/root/proc

chroot /data/overlay/root /bin/sh <<END
/data/gradient_provision.sh
END