{ pkgs, ports, ... }:
{

  services.wyoming.satellite = {
    enable = true;
    vad.enable = false;
    uri = "tcp://0.0.0.0:${toString ports.wyoming-satellite}";
    area = "Vera's Bedroom";
    user = "vera";
  };

  networking.firewall.interfaces.gradientnet.allowedTCPPorts = [
    ports.wyoming-satellite
  ];
  networking.firewall.interfaces.gradientnet.allowedUDPPorts = [
    ports.wyoming-satellite
  ];
}