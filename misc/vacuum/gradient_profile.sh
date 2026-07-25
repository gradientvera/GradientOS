#!/bin/sh

echo "-- Gradient Profile --"

export SOPS_AGE_KEY_FILE="/data/age/keys.txt"
export SOPS_SECRETS_FILE="/data/secrets/secrets.yml"

if [ -f "/sbin/apk"  ]; then
    echo " -- inside chroot --"
else
    echo " -- outside chroot --"
    if [ -d "/data/overlay/root" ]; then
        alias enter="chroot /data/overlay/root /bin/sh -l"
    fi
fi