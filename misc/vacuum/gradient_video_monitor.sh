#!/bin/sh

set -eu
set -o pipefail

exec >> /tmp/gradient.log
exec 2>&1

trap 'echo "Interrupted, stopping video monitor..."; kill $VIDEO_PID 2>/dev/null || true; exit 1' INT

STREAMER_DIR="/data/vacuumstreamer"
TMP_TAR="/tmp/streamer.tar.gz"
TMP_EXTRACT="/tmp/streamer_extract"

if [ ! -d "$STREAMER_DIR" ]; then
    echo "Please run \"just vacuumstreamer ROBOT_IP\" in the root of the GradientOS folder."
    exit 1
fi

if [ ! -f "/mnt/private/certificate.bin" ]; then
    echo "Remounting /mnt/private as rw..."
    mount -o remount,rw /mnt/private

    echo "Creating certificate.bin..."
    touch "/mnt/private/certificate.bin"

    echo "Remounting /mnt/private as ro..."
    mount -o remount,ro /mnt/private
fi

echo "Unmounting video_monitor config bind mount if already exists..."
if grep -q "$STREAMER_DIR/video_monitor-conf /ava/conf/video_monitor" /proc/mounts 2>/dev/null; then
    umount -f /ava/conf/video_monitor
fi

echo "Mounting video_monitor-conf..."
mount --bind "$STREAMER_DIR/video_monitor-conf" /ava/conf/video_monitor

GetDockedState () {
    if RESPONSE=$(curl -s -f -X 'GET' 'http://127.0.0.1:80/api/v2/robot/state/attributes' -H 'accept: application/json' 2>/dev/null); then
        if echo "$RESPONSE" | grep -q '"__class":"StatusStateAttribute","metaData":{},"value":"docked"'; then
            VALETUDO_DOCKED="true"
        else
            VALETUDO_DOCKED="false"
        fi
    else
        # Failed to reach Valetudo API, assume docked...
        VALETUDO_DOCKED="true"
    fi
}

LAST_FAIL=0

while true; do
    sleep 5

    GetDockedState

    VIDEO_PID=$(pidof video_monitor || true)

    if [ "$VALETUDO_DOCKED" = "true" ]; then
        if [ -n "$VIDEO_PID" ]; then
            echo "Robot docked, stopping video_monitor..."
            kill "$VIDEO_PID" 2>/dev/null || true
        fi
    else
        if [ -z "$VIDEO_PID" ]; then
            echo "Robot not docked, starting video_monitor..."
            LD_PRELOAD="$STREAMER_DIR/vacuumstreamer.so" $STREAMER_DIR/video_monitor &
            sleep 10
            if ! pidof video_monitor > /dev/null 2>&1; then
                echo "video_monitor failed to start, waiting before retrying..."
                sleep 25
            fi
        fi
    fi
done
