{ config, ports, ... }:
{

  services.homepage-dashboard = {
    widgets = [];
    services = [];
    docker = {
      asiyah = {
        socket = "/var/run/podman/podman.sock";
      };
    };
  };

  systemd.services.homepage-dashboard = {
    serviceConfig = {
      # Needed for Docker/Podman integration
      SupplementaryGroups = "podman";
    };
  };

}