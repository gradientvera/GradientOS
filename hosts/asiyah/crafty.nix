{ config, ports, ... }:
let
  addresses = config.gradient.const.addresses;
in
{

  systemd.tmpfiles.settings."99-crafty.conf" = 
  let
    rule = {
      mode = "0775";
    };
  in {
    "/var/lib/crafty".d = rule;
    "/var/lib/crafty/backups".d = rule;
    "/var/lib/crafty/logs".d = rule;
    "/var/lib/crafty/servers".d = rule;
    "/var/lib/crafty/config".d = rule;
    "/var/lib/crafty/import".d = rule;
  };

  virtualisation.oci-containers.containers.crafty = {
    image = "registry.gitlab.com/crafty-controller/crafty-4:latest";
    pull = "newer";
    ports = [
      "${addresses.podman-gateway}:${toString ports.crafty}:8443"
      "${addresses.podman-gateway}:${toString ports.crafty-dynmap}:8123"
      "${toString ports.crafty-server-start}-${toString ports.crafty-server-end}:${toString ports.crafty-server-start}-${toString ports.crafty-server-end}"
    ];
    volumes = [
      "/var/lib/crafty/backups:/crafty/backups"
      "/var/lib/crafty/logs:/crafty/logs"
      "/var/lib/crafty/servers:/crafty/servers"
      "/var/lib/crafty/config:/crafty/app/config"
      "/var/lib/crafty/import:/crafty/import"
    ];
    environment = {
      TZ = config.time.timeZone;
    };
  };

  networking.firewall.allowedTCPPortRanges = [
    { from = ports.crafty-server-start; to = ports.crafty-server-end; }
  ];

  networking.firewall.allowedUDPPortRanges = [
    { from = ports.crafty-server-start; to = ports.crafty-server-end; }
  ];

}