{ config, lib, ... }:
let
  addresses = config.gradient.const.wireguard.addresses;
  ports = import ./misc/service-ports.nix;
  asiyahPorts = import ../asiyah/misc/service-ports.nix;
in
{

  services.zigbee2mqtt = {
    enable = true;
    settings = {
      homeassistant = config.services.home-assistant.enable;
      mqtt = {
        server = "mqtt://${addresses.gradientnet.asiyah}:${toString asiyahPorts.mqtt}";
        include_device_information = true;
        version = 5;
      };
      serial = {
        port = "/dev/serial/by-id/usb-ITEAD_SONOFF_Zigbee_3.0_USB_Dongle_Plus_V2_20231121193348-if00";
        baudrate = 115200;
        adapter = "ember";
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

  networking.firewall.interfaces.gradientnet.allowedTCPPorts = [ ports.zigbee2mqtt ];
  networking.firewall.interfaces.gradientnet.allowedUDPPorts = [ ports.zigbee2mqtt ];

}