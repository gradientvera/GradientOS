#!/bin/sh

set -eu
set -o pipefail

exec >> /dev/kmsg
exec 2>&1

echo "Unmounting gradient overlay..."

umount /data/overlay/root/proc
umount /data/overlay/root/data
umount /data/overlay/root/tmp
umount /data/overlay/root/dev/shm
umount /data/overlay/root/dev
umount /data/overlay/root/mnt/private
umount /data/overlay/root/mnt/misc
umount /data/overlay/root/mnt
umount /data/overlay/root/sys
umount /data/overlay/root

echo "Gradient overlay unmounted. Maybe."