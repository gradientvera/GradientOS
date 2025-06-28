#!/bin/sh

echo "-- Gradient Profile --"

if [ -d "/opt/"  ]; then
    echo " -- inside chroot --"
    export PATH="$PATH:/opt/bin:/opt/sbin:/opt/usr/bin:/opt/libexec"
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/opt/lib:/opt/usr/lib"
else
    if [ -d "/data/overlay/root/opt" ]; then
        export PATH="$PATH:/data/overlay/root/opt/bin:/data/overlay/root/opt/sbin:/data/overlay/root/opt/usr/bin:/data/overlay/root/opt/libexec"
        export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/data/overlay/root/opt/lib:/data/overlay/root/opt/usr/lib"
    fi
fi