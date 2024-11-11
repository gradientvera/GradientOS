{ config, lib, ... }:
let
  ports = import ./misc/service-ports.nix;
in
{

  services.mosquitto = {
    enable = true;
    listeners = [
      # Listener for internal gradientnet purposes only. Do NOT expose.
      {
        acl = [ "pattern readwrite #" ];
        port = ports.mqtt;
        omitPasswordAuth = true;
        settings.allow_anonymous = true;
      }
    ];
  };  

  services.zigbee2mqtt = {
    enable = true;
    settings = {
      homeassistant = config.services.home-assistant.enable;
      mqtt = {
        server = "mqtt://localhost:${toString ports.mqtt}";
        include_device_information = true;
        version = 5;
      };
      serial = {
        port = "/dev/serial/by-id/usb-ITEAD_SONOFF_Zigbee_3.0_USB_Dongle_Plus_V2_20231121193348-if00";
        baudrate = 115200;
        rtscts = true;
      };
      availability = true;
      frontend = {
        port = ports.zigbee2mqtt;
      };
      advanced = {
        cache_state = true;
        last_seen = "ISO_8601";
        elapsed = true;
      };
    };  
  };

  systemd.services.zigbee2mqtt.serviceConfig = {
    Restart = lib.mkForce "always"; # Sometimes fails with successful exit code 
    RestartSec = 10;
  };

  networking.firewall.interfaces.gradientnet.allowedTCPPorts = [ ports.mqtt ports.zigbee2mqtt ];
  networking.firewall.interfaces.gradientnet.allowedUDPPorts = [ ports.mqtt ports.zigbee2mqtt ];

}