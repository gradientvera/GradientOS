{ ports, ... }:
{

  services.victoriametrics = {
    enable = true;
    listenAddress = ":${toString ports.victoriametrics}";
  };

  networking.firewall.interfaces.gradientnet.allowedTCPPorts = [
    ports.victoriametrics
  ];

}