{ ports, ... }:
{

  services.victorialogs = {
    enable = true;
    listenAddress = ":${toString ports.victorialogs}";
  };

  networking.firewall.interfaces.gradientnet.allowedTCPPorts = [
    ports.victorialogs
  ];

}