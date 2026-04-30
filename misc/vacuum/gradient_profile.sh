#!/bin/sh

echo "-- Gradient Profile --"

if [ -f "/sbin/apk"  ]; then
    echo " -- inside chroot --"
    export SOPS_AGE_KEY_FILE="/etc/age/keys.txt"
    export SOPS_SECRETS_FILE="/etc/secrets.yml"
else
    if [ -d "/data/overlay/root/etc/age" ]; then
        alias enter="chroot /data/overlay/root /bin/sh -l"
        export SOPS_AGE_KEY_FILE="/data/overlay/root/etc/age/keys.txt"
        export SOPS_SECRETS_FILE="/data/overlay/root/etc/secrets.yml"
    fi
fi