{ config, ports, ... }:
{

  services.microsocks = {
    enable = true;
    ip = config.gradient.const.wireguard.addresses.gradientnet.${config.networking.hostName};
    port = ports.microsocks;
  };

  networking.firewall.interfaces.gradientnet.allowedTCPPorts = [ ports.microsocks ];

}