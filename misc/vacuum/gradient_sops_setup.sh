#!/bin/sh

set -eu
set -o pipefail

echo "Initializing gradient_sops_setup..."

echo "Converting Dropbear host SSH key to OpenSSH format..."
dropbearconvert dropbear openssh /etc/dropbear/dropbear_ed25519_host_key /opt/etc/ssh/ssh_host_ed25519_key
ssh-keygen -f /opt/etc/ssh/ssh_host_ed25519_key -y > /opt/etc/ssh/ssh_host_ed25519_key.pub

echo "Converting OpenSSH host SSH keys to age keys..."
ssh-to-age -i /opt/etc/ssh/ssh_host_ed25519_key.pub -o /opt/etc/age/pub-keys.txt
ssh-to-age -i /opt/etc/ssh/ssh_host_ed25519_key -o /opt/etc/age/keys.txt -private-key
export SOPS_AGE_KEY_FILE="/opt/etc/age/keys.txt"