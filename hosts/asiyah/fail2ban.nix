{ config, ... }:
let
  addresses = config.gradient.const.wireguard.addresses;
in
{

  

  services.fail2ban = {
    enable = true;
    ignoreIP = [
      "${addresses.gradientnet.gradientnet}/24"
      "${addresses.lilynet.lilynet}/24"
    ];
    bantime-increment = {
      enable = true;
      rndtime = "24h";
      maxtime = "48h";
    };
  };

}