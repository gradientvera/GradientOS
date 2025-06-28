#!/bin/sh

set -eux
set -o pipefail

cd /tmp

mkdir -p /opt

wget https://bin.entware.net/aarch64-k3.10/installer/generic.sh

sh ./generic.sh
rm ./generic.sh

export PATH="$PATH:/opt/bin:/opt/usr/bin:/opt/libexec:/opt/sbin"

/opt/etc/init.d/rc.unslung start > /dev/null 2>&1 &

# Needed for Ansible
opkg install python3
opkg install openssh-sftp-server

rm -f /usr/libexec/sftp-server
ln -s /opt/libexec/sftp-server /usr/libexec/sftp-server

# SSH server with SFTP support
dropbear -s -p 222 > /dev/null 2>&1 &

