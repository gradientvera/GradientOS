#!/bin/sh

set -eu
set -o pipefail

exec >> /dev/kmsg
exec 2>&1

echo "Initializing gradient_provision..."

cd /tmp

mkdir -p /opt

echo "Waiting for network..."

# This script usually launches before the internet connection is established, so we wait
while ! ping -c 4 google.com > /dev/null; do
    sleep 1 
done

echo "Waiting for correct date and time..."

# Ensure date is set, wait as long as needed
while [ "$(date +%Y)" = "1970" ]; do
  sleep 1
done

echo "Current date time: $(date)"

echo "Downloading latest aarch64 entware installer..."

wget https://bin.entware.net/aarch64-k3.10/installer/generic.sh

echo "Installing entware..."

sh ./generic.sh
rm ./generic.sh

echo "Entware installed!"

export PATH="$PATH:/opt/bin:/opt/usr/bin:/opt/libexec:/opt/sbin"

echo "Running entware startup script..."

/opt/etc/init.d/rc.unslung start &

echo "Installing Ansible requirements through opkg..."

# Needed for Ansible
opkg install python3
opkg install openssh-sftp-server

rm -f /usr/libexec/sftp-server
ln -s /opt/libexec/sftp-server /usr/libexec/sftp-server

echo "Initializing dropbear daemon on chroot with SFTP support at port 222."

# SSH server with SFTP support
/usr/local/sbin/dropbear -s -p 222 &

echo "Initializing gradient_publish_photo daemon..."

# Publish camera photos to MQTT
/data/gradient_publish_photo.sh &