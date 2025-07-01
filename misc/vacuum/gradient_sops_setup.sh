#!/bin/sh

set -eu
set -o pipefail

echo "Initializing gradient_sops_setup..."

mkdir -p /opt/etc/ssh
mkdir -p /opt/etc/age

echo "Generating host SSH key if it does not exist yet..."
echo n | ssh-keygen -t ed25519 -P "" -N "" -f /opt/etc/ssh/ssh_host_ed25519_key -C "$(cat /etc/hostname)" >/dev/null 2>&1

echo "Converting OpenSSH host SSH keys to age keys..."
ssh-to-age -i /opt/etc/ssh/ssh_host_ed25519_key.pub -o /opt/etc/age/pub-keys.txt
ssh-to-age -i /opt/etc/ssh/ssh_host_ed25519_key -o /opt/etc/age/keys.txt -private-key

export SOPS_AGE_KEY_FILE="/opt/etc/age/keys.txt"
export SOPS_SECRETS_FILE="/opt/secrets.yml"