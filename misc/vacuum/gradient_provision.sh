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

echo "Fixing curl..."
opkg install curl
rm /usr/bin/curl
ln -s /opt/bin/curl /usr/bin/curl

echo "Fixing wget..."
opkg install wget-ssl
rm /usr/bin/wget
ln -s /opt/bin/wget /usr/bin/wget

echo "Initializing dropbear daemon on chroot with SFTP support at port 222."

# SSH server with SFTP support
/usr/local/sbin/dropbear -s -p 222 &

# Publish camera photos to MQTT
if [[ -x "/data/gradient_publish_photo.sh" ]]; then
  echo "Initializing gradient_publish_photo daemon..."
  /data/gradient_publish_photo.sh &
fi

# Oucher script
if [[ -x "/data/oucher/oucher.sh" ]]; then
  echo "Initializing Oucher daemon..."
	nohup /data/oucher/oucher.sh > /dev/null 2>&1 &
fi

if [ -f "/opt/bin/sops" ] && [ -f "/opt/bin/ssh-to-age" ] && [ -f "/data/gradient_sops_setup.sh" ]; then
  # Set up sops for secrets
  echo "Initializing SOPS setup..."
  /data/gradient_sops_setup.sh
fi

if [ -f "/opt/secrets.yml" ]; then
  # Initialize services which require secrets here
  echo "Initializing services with secrets..."
fi