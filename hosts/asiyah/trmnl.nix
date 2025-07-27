{ config, ... }:
let
  ports = config.gradient.currentHost.ports;
in
{

  virtualisation.oci-containers.containers.trmnl = {
    image = "ghcr.io/usetrmnl/byos_hanami:latest";
    pull = "newer";
    ports = [ "${toString ports.trmnl}:2300" ];
    environment = {
      TZ = config.time.timeZone;
      API_URI = "http://192.168.1.48:${toString ports.trmnl}";
      DATABASE_URL = "postgres://trmnl@host.containers.internal/trmnl";
    };
    extraOptions = [
      "--ip" "10.88.0.9"
    ];
    labels = { "io.containers.autoupdate" = "registry"; };
  };

  systemd.services.podman-trmnl = {
    after = [ "postgresql.service" ];
    wants = [ "postgresql.service" ];
  };

  networking.firewall.allowedTCPPorts = [
    ports.trmnl
  ];

}