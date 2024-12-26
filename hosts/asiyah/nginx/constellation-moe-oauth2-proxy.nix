{ config, ... }:
let
  secrets = config.sops.secrets;
  ports = import ../misc/service-ports.nix;
in {

  # TODO: Make this a container so we can have multiple instances of oauth2_proxy

  services.oauth2_proxy = {
    enable = true;
    provider = "github";
    httpAddress = "http://127.0.0.1:${toString ports.oauth2-proxy}";
    upstream = "http://127.0.0.1:${toString ports.nginx}";
    redirectURL = "https://polycule.constellation.moe/oauth2/callback";
    github.org = "ConstellationNRV";
    clientID = "05fb727827ad30eddf0d";
    keyFile = secrets.oauth2-proxy-secrets.path;
    reverseProxy = true;
    cookie.refresh = "1m";
    cookie.secure = true;
    cookie.httpOnly = false;
    cookie.domain = ".constellation.moe";
    extraConfig = {
      session-store-type = "redis";
      redis-connection-url = "redis://127.0.0.1:${toString ports.redis-oauth2}/0";
    };
    nginx.virtualHosts = {
      "polycule.constellation.moe" = {};
      # "jellyfin.constellation.moe" = {}; # Use built-in auth
      #"jellyseerr.constellation.moe" = {}; # Use built-in auth
      "unpackerr.constellation.moe" = {};
      "ersatztv.constellation.moe" = {};
      "radarr.constellation.moe" = {};
      "sonarr.constellation.moe" = {};
      "lidarr.constellation.moe" = {};
      "slskd.constellation.moe" = {};
      "readarr.constellation.moe" = {};
      "bazarr.constellation.moe" = {};
      "prowlarr.constellation.moe" = {};
      "tdarr.constellation.moe" = {};
      "torrent.constellation.moe" = {};
      "bitmagnet.constellation.moe" = {};
      "sabnzbd.constellation.moe" = {};
      "files.constellation.moe" = {};
      "search.constellation.moe" = {};
    };
    nginx.domain = "polycule.constellation.moe";
  };

  services.redis.servers.oauth2 = {
    enable = true;
    databases = 1;
    openFirewall = false;
    port = ports.redis-oauth2;
  };

  systemd.services.oauth2_proxy = {
    after = [ "redis-oauth2.service" ];
    wants = [ "redis-oauth2.service" ];
  };

  networking.firewall.allowedTCPPorts = with ports; [ oauth2-proxy ];

}