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

  echo "Fixing DNS config..."

  # Tailscale breaks resolv.conf unless tailscaled is running, so we fix this...
  echo "nameserver 1.1.1.1" > /etc/resolv.conf
  echo "nameserver 1.0.0.1" >> /etc/resolv.conf
  sleep 1

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
  apk add gcompat curl wget busybox nano espeak-ng jq

  export FRIENDLY_NAME=$(cat /data/valetudo_config.json | jq .valetudo.customizations.friendlyName -r)

  echo "Installing Pulseaudio emulator for ALSA..."
  apk add apulse --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing/

  echo "Installing updated Dropbear..."
  apk add python3 openssh-sftp-server dropbear dropbear-ssh

  ln -sf /usr/lib/ssh/sftp-server /usr/libexec/sftp-server

  echo "Fixing settings for Dropbear..."
  
  # Shells file does not exist by default
  rm -f /etc/shells
  echo "/bin/sh" > /etc/shells

  # Dropbear complains that /tmp (root $HOME) is writeable by anyone
  mkdir -p /root
  chmod -R 0600 /root
  chown root:root /root
  ln -sf /tmp/.ssh /root/.ssh

  echo "Initializing Dropbear daemon on chroot with SFTP support at port 222."

  # SSH server with SFTP support
  pkill -f "dropbear -s -E -p 222 -D /root/.ssh" || true
  /usr/sbin/dropbear -s -E -p 222 -D /root/.ssh &

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
    apk add mosquitto-clients imagemagick curl
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

  echo "Installing and executing MPD daemon..."
  apk add mpd
  pkill -f "mpd --no-config" || true
  mpd --no-config &

  # Tailscale
  mkdir -p /data/tailscale-state

  apk add tailscale
  pkill tailscaled || true
  rm -f /var/run/tailscale/tailscaled.sock || true
  /usr/sbin/tailscaled --no-logs-no-support --statedir=/data/tailscale-state > /dev/null 2>&1 &
  sleep 1
  tailscale_state=$(tailscale status --json --peers=false | jq -r '.BackendState')

  if [[ "$tailscale_state" != "Running" ]]; then
    echo "Starting Tailscale..."
    tailscale up --auth-key "$(sops decrypt --extract '["tailscale-auth-key"]' $SOPS_SECRETS_FILE)" '--login-server=https://headscale.constellation.moe' --hostname "$(cat /etc/hostname)"
  fi

  echo "Fixing Tailscale MagicDNS..."
  tailscale set --accept-dns=false > /dev/null 2>&1
  tailscale set --accept-dns=true > /dev/null 2>&1

  # Just in case?
  apk fix

  /usr/bin/speak "Gradient provision complete!" -v en --stdout | /bin/aplay
  echo "Gradient provision complete!"
}

until provision; do echo "Retrying provision in 5 seconds..."; sleep 5; done