{ config, lib, ports, ... }:
{

  services.uptime-kuma = {
    # borked: enable = true;
    appriseSupport = true;
    settings = {
      PORT = toString ports.uptime-kuma;
      UPTIME_KUMA_DB_TYPE = "sqlite";
    };
  };

  systemd.services.uptime-kuma = {
    serviceConfig = {
      # Needed for Docker/Podman integration
      SupplementaryGroups = "podman";
    };
  };

} 