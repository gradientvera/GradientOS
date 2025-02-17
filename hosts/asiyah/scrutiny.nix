{ config, ... }:
let
  ports = import ./misc/service-ports.nix;
in
{

  services.scrutiny = {
    enable = true;
    influxdb.enable = true;
    collector.enable = true;
    collector.settings.host.id = config.networking.hostName;
    settings.web.listen.port = ports.scrutiny;
    settings.web.influxdb.port = ports.influxdb;
  };

  services.influxdb2.settings.http-bind-address = ":${toString ports.influxdb}";

  networking.firewall.interfaces.gradientnet = with ports; {
    allowedTCPPorts = [
      scrutiny
      influxdb
    ];
    allowedUDPPorts = [
      scrutiny
      influxdb
    ];
  };

}