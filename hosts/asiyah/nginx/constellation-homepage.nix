{ config, ports, ... }:
{

  services.homepage-dashboard = {
    enable = true;
    listenPort = ports.constellation-homepage;
    # Not needed, we secure this with the firewall, OAuth2 Proxy and Nginx reverse proxy.
    allowedHosts = "*";
    widgets = [
      {
        resources = {
          label = "System";
          cpu = true;
          memory = true;
          network = true;
          cputemp = true;
          uptime = true;
          units = "metric";
          disk = "/";
        };
      }
      {
        resources = {
          label = "Storage";
          disk = "/data";
        };
      }
    ];
    services = [
      {
        "Media" = [
          {
            "Jellyfin" = {
              description = "Media solution that lets you stream your own media to any device.";
              href = "https://jellyfin.constellation.moe/";
            };
          }
        ];
      }
      {
        "Media Internal" = [
          {
            "Radarr" = {
              description = "Movie organizer/manager for usenet and torrent users.";
              href = "https://radarr.constellation.moe/";
            };
          }
          {
            "Sonarr" = {
              description = "Sonarr is a PVR for Usenet and BitTorrent users.";
              href = "https://sonarr.constellation.moe/";
            };
          }
        ];
      }
    ];
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