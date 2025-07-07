#!/bin/sh

# Needs valetudo, "camerademo" binary, imagemagick, jq, mosquitto-client-nossl...
# Very naive implementation not intended to be "good", just quick and simple.

set -eu
set -o pipefail

exec >> /dev/kmsg
exec 2>&1

trap 'echo "Interrupted, exiting camera publish now..."; exit 1' INT

GetVars () {
    export VALETUDO_CONFIG="/data/valetudo_config.json"
    export VALETUDO_ID=$(curl 'http://127.0.0.1:80/api/v2/valetudo' -H 'accept: application/json' | jq .systemId -r)
    export VALETUDO_ID_LOWER=$(echo $VALETUDO_ID | tr '[:upper:]' '[:lower:]')
    export VALETUDO_FRIENDLY_NAME=$(cat $VALETUDO_CONFIG | jq .valetudo.customizations.friendlyName -r)
    export VALETUDO_VERSION=$(cat $VALETUDO_CONFIG | jq ._version -r)
    export VALETUDO_DOCKED=$(curl -s -X 'GET' 'http://127.0.0.1:80/api/v2/robot/state/attributes' -H 'accept: application/json' | jq '.[] | select ( .__class == "StatusStateAttribute" ) | .value | . == "docked"')
    export MQTT_HOST=$(cat $VALETUDO_CONFIG | jq .mqtt.connection.host -r)
    export MQTT_PORT=$(cat $VALETUDO_CONFIG | jq .mqtt.connection.port -r)
    export TOPIC="valetudo/${VALETUDO_ID}/GradientPublishPhoto/file"
    export AUTODISCOVER=$(cat <<EOF
{
"name": "Main Camera",
"availability_topic": "valetudo/${VALETUDO_ID}/\$state",
"object_id": "valetudo_${VALETUDO_ID_LOWER}_gradient_main_camera",
"unique_id": "${VALETUDO_ID}_gradient_main_camera",
"payload_available": "ready",
"payload_not_available": "lost",
"topic": "${TOPIC}",
"device_class": "camera",
"device": {
    "identifiers": ["${VALETUDO_ID}"],
    "name": "${VALETUDO_FRIENDLY_NAME}"
  }
}
EOF
)
}

GetVars
mosquitto_pub -h "$MQTT_HOST" -p "$MQTT_PORT" -t "homeassistant/camera/${VALETUDO_ID}/${VALETUDO_ID}_gradient_camera/config" -r -m "${AUTODISCOVER}"

while true; do
    sleep 5

    # Get them every time in case some value changes
    GetVars

    if [ "$VALETUDO_DOCKED" = "true" ]; then
        continue
    fi;

    camerademo NV21 640 480 0 bmp /tmp 1 >> /dev/null || continue

    magick /tmp/bmp_NV21_1.bmp /tmp/bmp_NV21_1.jpg || continue

    mosquitto_pub -h "$MQTT_HOST" -p "$MQTT_PORT" -t $TOPIC -r -f /tmp/bmp_NV21_1.jpg || continue

    rm /tmp/bmp_NV21_1.bmp /tmp/bmp_NV21_1.jpg || continue
done