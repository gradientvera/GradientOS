{ config, lib, ... }:
let
  ports = config.gradient.currentHost.ports;
in
{

  services.esphome = {
    enable = true;
    usePing = true;
    address = "0.0.0.0";
    port = ports.esphome;
  };

  users.users.esphome = {
    isSystemUser = true;
    home = "/var/lib/esphome";
    createHome = true;
    homeMode = "750";
    group = config.users.groups.esphome.name;
  };

  users.groups.esphome = {};

  systemd.services.esphome = {
    serviceConfig = {
      # Needed to fix compilation
      DynamicUser = lib.mkForce false;
      User = lib.mkForce config.users.users.esphome.name;
      Group = lib.mkForce config.users.groups.esphome.name;
      PrivateTmp = lib.mkForce true;
      RemoveIPC = lib.mkForce true;
      RestrictSUIDSGID = lib.mkForce true;
    };
  };

  systemd.tmpfiles.settings."10-esphome" = 
  let
    mkDevice = file: {
      argument = toString ./${file};
      repoPath = "/etc/nixos/hosts/asiyah/esphome/${file}";
      doCheck = true;
      user = config.systemd.services.esphome.serviceConfig.User;
      group = config.systemd.services.esphome.serviceConfig.Group;
      mode = "0755";
    };
  in
  {
    "/var/lib/esphome/bk7231n-ir-blaster.yaml".C = mkDevice "bk7231n-ir-blaster.yaml";
    "/var/lib/esphome/kaysun-ac-living-room.yaml".C = mkDevice "kaysun-ac-living-room.yaml";
    "/var/lib/esphome/kaysun-ac-vera-bedroom.yaml".C = mkDevice "kaysun-ac-vera-bedroom.yaml";
    "/var/lib/esphome/sonoff-rf-bridge-r2.yaml".C = mkDevice "sonoff-rf-bridge-r2.yaml";
    "/var/lib/esphome/smart-air-freshener.yaml".C = mkDevice "smart-air-freshener.yaml";
    "/var/lib/esphome/espbell-lite.yaml".C = mkDevice "espbell-lite.yaml";
  };

  networking.firewall.interfaces.gradientnet.allowedTCPPorts = [ ports.esphome ];
  networking.firewall.interfaces.gradientnet.allowedUDPPorts = [ ports.esphome ];

}