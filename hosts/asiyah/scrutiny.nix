{ ... }:
let
  ports = import ./misc/service-ports.nix;
in
{

  services.scrutiny = {
    enable = true;
    influxdb.enable = false;
    collector.enable = true;
    settings.web.listen.port = ports.scrutiny;
    settings.web.listen.host = "127.0.0.1";
    settings.web.influxdb.port = ports.influxdb;
    settings.web.influxdb.host = "127.0.0.1";
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