{ ... }:
{

  programs.weylus = {
    enable = true;
    users = [ "vera" ];
    openFirewall = false;
  };

  networking.firewall.interfaces.gradientnet.allowedTCPPorts = [
    1701
    9001
  ];

}