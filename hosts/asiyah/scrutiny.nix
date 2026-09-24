{ config, ... }:
let
  ports = config.gradient.currentHost.ports;
in
{

  services.scrutiny = {
    enable = true;
    influxdb.enable = true;
    collector.enable = true;
    collector.settings.host.id = config.networking.hostName;
    settings = {
      web.listen.port = ports.scrutiny;
      web.influxdb.host = "127.0.0.1";
      web.influxdb.port = ports.influxdb;
    };
  };

  services.influxdb2.settings.http-bind-address = "127.0.0.1:${toString ports.influxdb}";

  networking.firewall.interfaces.gradientnet = with ports; {
    allowedTCPPorts = [
      scrutiny
    ];
    allowedUDPPorts = [
      scrutiny
    ];
  };

}
