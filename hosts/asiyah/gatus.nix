{
  config,
  ports,
  ...
}:
let
  addresses = config.gradient.const.addresses;
  podman = addresses.podman-gateway;
  local = "127.0.0.1";

  webhook = [
    {
      type = "webhook";
    }
  ];

  mkPublic =
    {
      name,
      url,
      conditions ? [ "[STATUS] == 200" ],
      interval ? "5m",
    }:
    {
      inherit
        name
        url
        interval
        conditions
        ;
      group = "Public";
      alerts = webhook;
    };

  mkMedia =
    {
      name,
      port,
      address ? podman,
      path ? "",
      conditions ? [ "[STATUS] < 500" ],
    }:
    {
      inherit name conditions;
      url = "http://${address}:${toString port}${path}";
      interval = "10m";
      group = "Media";
      alerts = webhook;
    };

  mkInfra =
    {
      name,
      url,
      conditions ? [ "[STATUS] == 200" ],
    }:
    {
      inherit name url conditions;
      interval = "5m";
      group = "Infra";
      alerts = webhook;
    };

  mkTcp = name: address: port: {
    inherit name;
    url = "tcp://${address}:${toString port}";
    interval = "5m";
    group = "Infra";
    conditions = [ "[CONNECTED] == true" ];
    alerts = webhook;
  };

  mkDns = name: hostname: {
    inherit name;
    url = "1.1.1.1";
    interval = "30m";
    group = "Network";
    dns.query-type = "A";
    dns.query-name = hostname;
    conditions = [ "[DNS_RCODE] == NOERROR" ];
    alerts = webhook;
  };
in
{

  services.gatus = {
    enable = true;
    # See https://gatus.io/docs and https://github.com/TwiN/gatus#configuration-1
    settings = {
      web = {
        address = "127.0.0.1";
        port = ports.gatus;
      };

      ui = {
        title = "Health Dashboard | Constellation Services";
        header = "Constellation";
        link = "https://homepage.constellation.moe";
        logo = "https://constellation.moe/images/favicon.svg";
        favicon.default = "https://constellation.moe/images/favicon.svg";
        description = "Uptime and health status for the Constellation and Gradient services.";
        dashboard-subheading = "";
      };

      storage = {
        type = "sqlite";
        path = "/var/lib/gatus/data.db";
        caching = true;
      };

      endpoints = [
        (mkPublic {
          name = "constellation.moe";
          url = "https://constellation.moe";
          conditions = [
            "[STATUS] == 200"
            "[CONNECTED] == true"
            "[CERTIFICATE_EXPIRATION] > 48h"
            "[DOMAIN_EXPIRATION] > 48h"
          ];
        })

        (mkPublic {
          name = "gradient.moe";
          url = "https://gradient.moe";
          conditions = [
            "[STATUS] == 200"
            "[CONNECTED] == true"
            "[CERTIFICATE_EXPIRATION] > 48h"
            "[DOMAIN_EXPIRATION] > 48h"
          ];
        })

        # nginx + oauth2-proxy canary
        (mkPublic {
          name = "nginx + oauth2-proxy";
          url = "https://homepage.constellation.moe";
          conditions = [ "[STATUS] < 500" ];
        })

        # Public gradient.moe
        (mkPublic {
          name = "Gradient Git";
          url = "https://git.gradient.moe/api/healthz";
        })
        (mkPublic {
          name = "Gradient Identity";
          url = "https://identity.gradient.moe";
        })
        (mkPublic {
          name = "Gradient Cache";
          url = "https://cache.gradient.moe";
        })
        (mkPublic {
          name = "Grafana";
          url = "https://grafana.gradient.moe/api/health";
        })
        (mkPublic {
          name = "Paperless";
          url = "https://paperless.gradient.moe";
        })
        (mkPublic {
          name = "Home Assistant";
          url = "https://hass.gradient.moe";
          conditions = [ "[STATUS] < 500" ];
        })

        # Public constellation.moe
        (mkPublic {
          name = "Immich";
          url = "https://immich.constellation.moe/api/server/ping";
        })
        # Jellyfin has its own auth
        {
          name = "Jellyfin";
          group = "Media";
          url = "http://jellyfin.constellation.moe/health";
          interval = "5m";
          conditions = [
            "[STATUS] == 200"
            "[BODY] == Healthy"
          ];
          alerts = webhook;
        }

        # Media stack
        (mkMedia {
          name = "Jellyseerr";
          port = ports.jellyseerr;
        })
        (mkMedia {
          name = "Radarr";
          port = ports.radarr;
        })
        (mkMedia {
          name = "Radarr (ES)";
          port = ports.radarr-es;
        })
        (mkMedia {
          name = "Sonarr";
          port = ports.sonarr;
        })
        (mkMedia {
          name = "Sonarr (ES)";
          port = ports.sonarr-es;
        })
        (mkMedia {
          name = "Lidarr";
          port = ports.lidarr;
        })
        (mkMedia {
          name = "Bazarr";
          port = ports.bazarr;
        })
        (mkMedia {
          name = "Prowlarr";
          port = ports.prowlarr;
        })
        (mkMedia {
          name = "Profilarr";
          port = ports.profilarr;
        })
        (mkMedia {
          name = "Tdarr";
          port = ports.tdarr-webui;
        })
        (mkMedia {
          name = "qBittorrent";
          port = ports.qbittorrent-webui;
        })
        (mkMedia {
          name = "SABnzbd";
          port = ports.sabnzbd;
        })
        (mkMedia {
          name = "slskd";
          port = ports.slskd;
        })
        (mkMedia {
          name = "aMule (web)";
          port = ports.amule-web-controller;
        })
        (mkMedia {
          name = "aMule (webui)";
          port = ports.amule-webui;
        })
        (mkMedia {
          name = "ErsatzTV";
          port = ports.ersatztv;
        })
        (mkMedia {
          name = "Pinchflat";
          port = ports.pinchflat;
        })
        (mkMedia {
          name = "Threadfin";
          port = ports.threadfin;
          path = "/web/";
        })
        (mkMedia {
          name = "Files";
          port = ports.mikochi;
        })
        (mkMedia {
          name = "Calibre";
          port = ports.calibre-web-automated;
        })
        (mkMedia {
          name = "Shelfmark";
          port = ports.shelfmark;
        })
        (mkMedia {
          name = "RomM";
          port = ports.romm;
        })
        (mkMedia {
          name = "OliveTin";
          port = ports.olivetin;
          address = local;
        })
        (mkMedia {
          name = "Radio";
          port = ports.openwebrx;
        })
        (mkMedia {
          name = "Crafty dynmap";
          port = ports.crafty-dynmap;
        })
        # Crafty's web UI is https with a self-signed cert, so probe it
        # through the (oauth2-protected) public vhost instead.
        (mkPublic {
          name = "Crafty";
          url = "https://crafty.constellation.moe";
          conditions = [ "[STATUS] < 500" ];
        })

        # Infra: native services on loopback with known health endpoints.
        (mkInfra {
          name = "SearXNG";
          url = "http://${local}:${toString ports.searx}/healthz";
        })
        (mkInfra {
          name = "Vaultwarden";
          url = "http://${local}:${toString ports.vaultwarden}/alive";
        })
        (mkInfra {
          name = "VictoriaMetrics";
          url = "http://${local}:${toString ports.victoriametrics}/health";
        })
        (mkInfra {
          name = "VictoriaLogs";
          url = "http://${local}:${toString ports.victorialogs}/health";
        })
        (mkInfra {
          name = "Scrutiny";
          url = "http://${local}:${toString ports.scrutiny}/api/health";
        })
        (mkInfra {
          name = "Frigate";
          url = "http://${local}:${toString ports.frigate}";
          conditions = [ "[STATUS] < 500" ];
        })
        (mkInfra {
          name = "ESPHome";
          url = "http://${local}:${toString ports.esphome}";
          conditions = [ "[STATUS] < 500" ];
        })
        (mkInfra {
          name = "Trilium";
          url = "http://${local}:${toString ports.trilium}";
          conditions = [ "[STATUS] < 500" ];
        })

        # Databases and brokers, TCP only
        (mkTcp "PostgreSQL" local ports.postgresql)
        (mkTcp "Redis (forgejo)" local ports.redis-forgejo)
        (mkTcp "MQTT" local ports.mqtt)

        # DNS resolution and edge services on briah
        (mkDns "DNS constellation.moe" "constellation.moe")
        (mkDns "DNS gradient.moe" "gradient.moe")
        (mkPublic {
          name = "Headscale";
          url = "https://headscale.constellation.moe/health";
        })
      ];
    };
  };

}
