#!/bin/sh

set -eu
set -o pipefail

exec >> /tmp/gradient.log
exec 2>&1

provision() {
  set -eu
  set -o pipefail

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

  echo "Downloading Alpine mini root filesystem..."

  rm -rf /tmp/alpine
  mkdir /tmp/alpine
  wget https://dl-cdn.alpinelinux.org/alpine/v3.23/releases/aarch64/alpine-minirootfs-3.23.4-aarch64.tar.gz -O alpine.tar.gz
  tar -xvzf ./alpine.tar.gz -C /tmp/alpine

  cp -a /tmp/alpine/lib/. /lib/
  cp -a /tmp/alpine/sbin/apk /sbin/
  cp -a /tmp/alpine/usr/lib/. /usr/lib/
  cp -a /tmp/alpine/usr/share/apk /usr/share
  cp -a /tmp/alpine/etc/apk /etc/
  cp -a /tmp/alpine/etc/ssl /etc/
  cp -a /tmp/alpine/etc/ssl1.1 /etc/
  cp -a /tmp/alpine/var/cache/apk /var/cache/
  rm -rf /tmp/alpine
  rm -f /tmp/alpine.tar.gz

  echo "Alpine installed on overlay!"

  apk update

  echo "Fixing busybox and ca-certificates..."
  apk fix --reinstall busybox
  apk fix --reinstall ca-certificates

  echo "Installing system utilities..."
  apk add gcompat curl wget busybox nano espeak-ng

  echo "Installing Ansible requirements through apk..."
  apk add python3 openssh-sftp-server

  ln -sf /usr/lib/ssh/sftp-server /usr/libexec/sftp-server

  echo "Initializing dropbear daemon on chroot with SFTP support at port 222."

  # SSH server with SFTP support
  pkill -f "dropbear -s -p 222" || true
  /usr/local/sbin/dropbear -s -p 222 &

  echo "Installing sops and age..."
  apk add sops age

  mkdir -p /etc/age

  if ! [ -f "/etc/age/keys.txt" ]; then
      echo "Generating age keys..."
      age-keygen -o /etc/age/keys.txt
      age-keygen -y /etc/age/keys.txt > /etc/age/pub-keys.txt
  fi

  export SOPS_AGE_KEY_FILE="/etc/age/keys.txt"
  export SOPS_SECRETS_FILE="/etc/secrets.yml"

  # Publish camera photos to MQTT
  if [[ -x "/data/gradient_publish_photo.sh" ]]; then
    echo "Initializing gradient_publish_photo daemon..."
    echo "Installing dependencies for gradient_publish_photo..."
    apk add mosquitto-clients imagemagick curl jq
    pkill gradient_publish_photo.sh || true
    /data/gradient_publish_photo.sh &
  fi

  # Oucher script
  if [[ -x "/data/oucher/oucher.sh" ]]; then
    echo "Initializing Oucher daemon..."
    echo "Installing dependencies for oucher..."
    apk add strace ffmpeg vorbis-tools libao # + curl + jq
    pkill oucher.sh || true
    /data/oucher/oucher.sh &
  fi

  # Just in case?
  apk fix

  /usr/bin/speak "Gradient provision complete!" -v en --stdout | /bin/aplay
  echo "Gradient provision complete!"
}

until provision; do echo "Retrying provision in 5 seconds..."; sleep 5; done