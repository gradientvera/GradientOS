{ config, lib, ... }:
let
  ports = config.gradient.currentHost.ports;
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

  networking.firewall.interfaces.gradientnet.allowedTCPPorts = [ ports.mqtt ];
  networking.firewall.interfaces.gradientnet.allowedUDPPorts = [ ports.mqtt ];

}