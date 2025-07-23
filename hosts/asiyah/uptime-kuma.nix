{ config, lib, ports, ... }:
{

  services.uptime-kuma = {
    enable = true;
    appriseSupport = true;
    settings = {
      PORT = toString ports.uptime-kuma;
      UPTIME_KUMA_DB_TYPE = "sqlite";
    };
  };

  users.users.uptime-kuma = {
    isSystemUser = true;
    home = "/var/lib/uptime-kuma";
    createHome = true;
    homeMode = "750";
    group = config.users.groups.uptime-kuma.name;
    extraGroups = [ "podman" ];
  };

  users.groups.uptime-kuma = {};

  systemd.services.uptime-kuma = {
    serviceConfig = {
      # Needed for Docker/Podman integration
      DynamicUser = lib.mkForce false;
      User = lib.mkForce config.users.users.uptime-kuma.name;
      Group = lib.mkForce config.users.groups.uptime-kuma.name;
      PrivateTmp = lib.mkForce true;
      RemoveIPC = lib.mkForce true;
      RestrictSUIDSGID = lib.mkForce true;
    };
  };

} 