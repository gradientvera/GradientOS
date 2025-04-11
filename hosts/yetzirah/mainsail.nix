{ config, ... }:
let
  ports = config.gradient.currentHost.ports;
  addresses = config.gradient.const.wireguard.addresses;
  hostName = config.networking.hostName;
in {

  services.mainsail = {
    enable = true;
    nginx.listen = [
      {
        addr = "127.0.0.1";
        port = ports.mainsail;
      }
      {
        addr = addresses.gradientnet.${hostName};
        port = ports.mainsail;
      }
      {
        addr = addresses.lilynet.${hostName};
        port = ports.mainsail;
      }
    ];
    nginx.serverAliases = [
      "mainsail.${hostName}.constellation.moe"
      "mainsail.${hostName}.gradient.moe"
      "${hostName}.gradient"
      "${hostName}.lily"
    ];
  };

  # Increase max upload size for uploading gcode files from PrusaSlicer
  services.nginx.clientMaxBodySize = "4G";

  networking.firewall.interfaces.gradientnet.allowedTCPPorts = [ ports.mainsail ];
  networking.firewall.interfaces.gradientnet.allowedUDPPorts = [ ports.mainsail ];

  networking.firewall.interfaces.lilynet.allowedTCPPorts = [ ports.mainsail ];
  networking.firewall.interfaces.lilynet.allowedUDPPorts = [ ports.mainsail ];

}