{ config, ports, ... }:
let
  directory = "/var/lib/trmnl";
in
{

  systemd.tmpfiles.settings."99-trmnl".${directory}.d = {
    mode = "750";
    user = "nobody";
    group = "nogroup";
  };

  virtualisation.oci-containers.containers.trmnl = {
    image = "docker.io/wojooo/inker:latest";
    pull = "newer";
    ports = [ "0.0.0.0:${toString ports.trmnl}:80" ];
    environment = {
      TZ = config.time.timeZone;
      ADMIN_PIN = "1111";
      CORS_ORIGINS = "*";
    };
    volumes = [
      "${directory}:/app/uploads"
    ];
    extraOptions = [
    ];
    labels = {
      "io.containers.autoupdate" = "registry";
    };
  };

  networking.firewall.allowedTCPPorts = [
    ports.trmnl
  ];

}
