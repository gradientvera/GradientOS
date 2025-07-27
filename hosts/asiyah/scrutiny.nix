{ config, ... }:
let
  ports = config.gradient.currentHost.ports;
in
{

  # TODO: Fix this stuff
  services.scrutiny = {
    enable = false;
    influxdb.enable = false;
    collector.enable = true;
    collector.settings.host.id = config.networking.hostName;
    settings.web.listen.port = ports.scrutiny;
  };

  networking.firewall.interfaces.gradientnet = with ports; {
    allowedTCPPorts = [
      scrutiny
    ];
    allowedUDPPorts = [
      scrutiny
    ];
  };

}