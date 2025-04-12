{ config, ... }:
let
  ports = config.gradient.currentHost.ports;
in
{

  systemd.tmpfiles.settings."10-trmnl.conf" =
  let
    rule = {
      mode = "0700";
    };
  in
  {
    "/var/lib/trmnl".d = rule;
    "/var/lib/trmnl/database".d = rule;
    "/var/lib/trmnl/storage".d = rule;
  };

  virtualisation.oci-containers.containers.trmnl = {
    image = "ghcr.io/usetrmnl/byos_laravel:0.1.9";
    pull = "newer";
    ports = [
      "${toString ports.trmnl}:8080"
    ];
    volumes = [
      "/var/lib/trmnl/database:/var/www/html/database"
      "/var/lib/trmnl/storage:/var/www/html/storage"
    ];
    environment = {
      REGISTRATION_ENABLED = "0";
      PHP_OPCACHE_ENABLE = "1";
    };
    extraOptions = [
      "--ip=10.88.0.8"
    ];
  };

  networking.firewall.allowedTCPPorts = [
    ports.trmnl
  ];

}