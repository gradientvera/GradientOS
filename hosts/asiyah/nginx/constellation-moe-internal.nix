{
  config,
  self,
  lib,
  ...
}:
let
  addresses = config.gradient.const.addresses;
  ports = config.gradient.currentHost.ports;
  # TODO: This is copy-pasted... Make this a common lib or something?
  #       or even better, make a NixOS module for it hoooly shit
  mkReverseProxy =
    {
      port,
      address ? "127.0.0.1",
      protocol ? "http",
      generateOwnCert ? false,
      rootExtraConfig ? "",
      vhostExtraConfig ? "",
      reverseProxyLocation ? "/",
      reverseProxySubdomain ? "",
      useACMEHost ? "constellation.moe",
      extraConfig ? { },
    }:
    (lib.recursiveUpdate {
      useACMEHost = if (!generateOwnCert) then useACMEHost else null;
      enableACME = generateOwnCert;
      quic = true;
      forceSSL = true;
      extraConfig = ''
        ${vhostExtraConfig}
      '';
      locations.${reverseProxyLocation} = {
        proxyPass = "${protocol}://${address}:${toString port}${reverseProxySubdomain}";
        proxyWebsockets = true;
        extraConfig = ''
          auth_request_set $preferredusername $upstream_http_x_auth_request_preferred_username;
          proxy_set_header X-Username $xusername;

          auth_request_set $groups $upstream_http_x_auth_request_groups;
          proxy_set_header X-Groups $groups;
          ${rootExtraConfig}
        '';
      };
    } extraConfig);
in
{

  services.nginx.virtualHosts."polycule.constellation.moe" = {
    useACMEHost = "constellation.moe";
    forceSSL = true;
    extraConfig = ''
      # fix issues with oauth2 proxy
      proxy_buffer_size 32k;
      proxy_buffers 4 64k;
      proxy_busy_buffers_size 64k;
    '';
    locations."/" = {
      return = "301 https://homepage.constellation.moe$request_uri";
    };
  };

  services.nginx.virtualHosts."jellyfin.constellation.moe" = {
    useACMEHost = "constellation.moe";
    addSSL = true;
    quic = lib.mkForce false;

    extraConfig = ''
      # # https://jellyfin.org/docs/general/post-install/networking/reverse-proxy/nginx/
      ## The default `client_max_body_size` is 1M, this might not be enough for some posters, etc.
      client_max_body_size 200M;

      # Comment next line to allow TLSv1.0 and TLSv1.1 if you have very old clients
      ssl_protocols TLSv1.3 TLSv1.2;

      # Security / XSS Mitigation Headers
      add_header X-Content-Type-Options "nosniff";

      # Permissions policy. May cause issues with some clients
      add_header Permissions-Policy "accelerometer=(), ambient-light-sensor=(), battery=(), bluetooth=(), camera=(), clipboard-read=(), display-capture=(), document-domain=(), encrypted-media=(), gamepad=(), geolocation=(), gyroscope=(), hid=(), idle-detection=(), interest-cohort=(), keyboard-map=(), local-fonts=(), magnetometer=(), microphone=(), payment=(), publickey-credentials-get=(), serial=(), sync-xhr=(), usb=(), xr-spatial-tracking=()" always;

      # Content Security Policy
      # See: https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP
      # Enforces https content and restricts JS/CSS to origin
      # External Javascript (such as cast_sender.js for Chromecast) must be whitelisted.
      add_header Content-Security-Policy "default-src https: data: blob: ; img-src 'self' https://* ; style-src 'self' 'unsafe-inline'; script-src 'self' 'unsafe-inline' https://www.gstatic.com https://www.youtube.com blob:; worker-src 'self' blob:; connect-src 'self'; object-src 'none'; frame-ancestors 'self'; font-src 'self'";
    '';

    locations."/".extraConfig = ''
      # https://jellyfin.org/docs/general/post-install/networking/reverse-proxy/nginx/
      # Proxy main Jellyfin traffic
      proxy_pass http://${addresses.podman-gateway}:${toString ports.jellyfin-http};
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
      proxy_set_header X-Forwarded-Protocol $scheme;
      proxy_set_header X-Forwarded-Host $http_host;

      # Disable buffering when the nginx proxy gets very resource heavy upon streaming
      proxy_buffering off;
      proxy_cache off;
    '';

    locations."/socket".extraConfig = ''
      # https://jellyfin.org/docs/general/post-install/networking/reverse-proxy/nginx/
      # Proxy Jellyfin Websockets traffic
      proxy_pass http://${addresses.podman-gateway}:${toString ports.jellyfin-http};
      proxy_http_version 1.1;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection "upgrade";
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
      proxy_set_header X-Forwarded-Protocol $scheme;
      proxy_set_header X-Forwarded-Host $http_host;
    '';
  };

  services.nginx.virtualHosts = {
    "homepage.constellation.moe" = mkReverseProxy { port = ports.constellation-homepage; };
    "status.constellation.moe" = mkReverseProxy { port = ports.gatus; };
    "ersatztv.constellation.moe" = mkReverseProxy {
      port = ports.ersatztv;
      address = addresses.podman-gateway;
      rootExtraConfig = "proxy_cache off; proxy_buffering off;";
      extraConfig = {
        quic = lib.mkForce false;
        http3_hq = lib.mkForce false;
      };
    };
    "iptv.constellation.moe" = mkReverseProxy {
      port = ports.ersatztv;
      address = addresses.podman-gateway;
      reverseProxyLocation = "/iptv";
      reverseProxySubdomain = "/iptv";
      rootExtraConfig = "proxy_buffering off; proxy_cache off; add_header 'Cache-Control' 'no-store, no-cache, must-revalidate, proxy-revalidate, max-age=0'; add_header Pragma 'no-cache'; add_header Expires 0;";
    };
    "jellyseerr.constellation.moe" = mkReverseProxy {
      port = ports.jellyseerr;
      address = addresses.podman-gateway;
    };
    "radarr.constellation.moe" = mkReverseProxy {
      port = ports.radarr;
      address = addresses.podman-gateway;
    };
    "sonarr.constellation.moe" = mkReverseProxy {
      port = ports.sonarr;
      address = addresses.podman-gateway;
    };
    "radarr-es.constellation.moe" = mkReverseProxy {
      port = ports.radarr-es;
      address = addresses.podman-gateway;
    };
    "sonarr-es.constellation.moe" = mkReverseProxy {
      port = ports.sonarr-es;
      address = addresses.podman-gateway;
    };
    "amule.constellation.moe" = mkReverseProxy {
      port = ports.amule-web-controller;
      address = addresses.podman-gateway;
    };
    "amuleui.constellation.moe" = mkReverseProxy {
      port = ports.amule-webui;
      address = addresses.podman-gateway;
    };
    "lidarr.constellation.moe" = mkReverseProxy {
      port = ports.lidarr;
      address = addresses.podman-gateway;
    };
    "slskd.constellation.moe" = mkReverseProxy {
      port = ports.slskd;
      address = addresses.podman-gateway;
    };
    "bazarr.constellation.moe" = mkReverseProxy {
      port = ports.bazarr;
      address = addresses.podman-gateway;
    };
    "prowlarr.constellation.moe" = mkReverseProxy {
      port = ports.prowlarr;
      address = addresses.podman-gateway;
    };
    "profilarr.constellation.moe" = mkReverseProxy {
      port = ports.profilarr;
      address = addresses.podman-gateway;
    };
    "tdarr.constellation.moe" = mkReverseProxy {
      port = ports.tdarr-webui;
      address = addresses.podman-gateway;
    };
    "torrent.constellation.moe" = mkReverseProxy {
      port = ports.qbittorrent-webui;
      address = addresses.podman-gateway;
    };
    "sabnzbd.constellation.moe" = mkReverseProxy {
      port = ports.sabnzbd;
      address = addresses.podman-gateway;
    };
    "romm.constellation.moe" = mkReverseProxy {
      port = ports.romm;
      address = addresses.podman-gateway;
    };
    "search.constellation.moe" = mkReverseProxy { port = ports.searx; };
    "files.constellation.moe" = mkReverseProxy {
      port = ports.mikochi;
      address = addresses.podman-gateway;
    };
    "calibre.constellation.moe" = mkReverseProxy {
      port = ports.calibre-web-automated;
      address = addresses.podman-gateway;

      vhostExtraConfig = ''
        client_max_body_size 4G;
        proxy_buffer_size 128k;
        proxy_buffers 4 256k;
        proxy_busy_buffers_size 256k;
      '';
      # Yes the ending / is there on purpose
      extraConfig.locations."/kobo/".extraConfig = ''
        auth_request off;
        proxy_pass http://${addresses.podman-gateway}:${toString ports.calibre-web-automated};
      '';
      extraConfig.locations."/opds".extraConfig = ''
        auth_request off;
        auth_basic_user_file ${config.sops.secrets.calibre-opds-credentials.path};
        proxy_pass http://${addresses.podman-gateway}:${toString ports.calibre-web-automated};
      '';
    };
    "shelfmark.constellation.moe" = mkReverseProxy {
      port = ports.shelfmark;
      address = addresses.podman-gateway;
    };
    "radio.constellation.moe" = mkReverseProxy {
      port = ports.openwebrx;
      address = addresses.podman-gateway;
    };
    "k1c.constellation.moe" = mkReverseProxy {
      address = "192.168.1.27";
      port = 80;
    };
    "pinchflat.constellation.moe" = mkReverseProxy {
      port = ports.pinchflat;
      address = addresses.podman-gateway;
    };
    "crafty.constellation.moe" = mkReverseProxy {
      port = ports.crafty;
      address = addresses.podman-gateway;
      protocol = "https";
    };
    "olivetin.constellation.moe" = mkReverseProxy { port = ports.olivetin; };
    "threadfin.constellation.moe" = mkReverseProxy {
      port = ports.threadfin;
      address = addresses.podman-gateway;
    };
    "immich.constellation.moe" = mkReverseProxy {
      port = ports.immich;
      vhostExtraConfig = ''
        client_max_body_size 50G;
        client_body_buffer_size 1024k;
        proxy_request_buffering off;
      '';
    };
  };

  # TODO: Figure out a way to automate the below list eugh
  services.oauth2-proxy.nginx.virtualHosts =
    let
      constellation-only = {
        allowed_groups = [ "constellation" ];
      };
      everyone = {
        allowed_groups = null;
      };
    in
    {
      "homepage.constellation.moe" = constellation-only;
      "status.constellation.moe" = everyone;
      "polycule.constellation.moe" = constellation-only;
      # "jellyfin.constellation.moe" = {}; # Use built-in auth
      "ersatztv.constellation.moe" = constellation-only;
      # "iptv.constellation.moe" = {}; # Use built-in auth
      # "jellyseerr.constellation.moe" = {}; # Use built-in auth
      "radarr.constellation.moe" = constellation-only;
      "sonarr.constellation.moe" = constellation-only;
      "radarr-es.constellation.moe" = constellation-only;
      "sonarr-es.constellation.moe" = constellation-only;
      "amule.constellation.moe" = constellation-only;
      "amuleui.constellation.moe" = constellation-only;
      "lidarr.constellation.moe" = constellation-only;
      "slskd.constellation.moe" = constellation-only;
      "bazarr.constellation.moe" = constellation-only;
      "prowlarr.constellation.moe" = constellation-only;
      "profilarr.constellation.moe" = constellation-only;
      "tdarr.constellation.moe" = constellation-only;
      "torrent.constellation.moe" = constellation-only;
      "sabnzbd.constellation.moe" = constellation-only;
      "romm.constellation.moe" = constellation-only;
      "search.constellation.moe" = constellation-only;
      "files.constellation.moe" = constellation-only;
      "calibre.constellation.moe" = constellation-only;
      "shelfmark.constellation.moe" = constellation-only;
      "radio.constellation.moe" = constellation-only;
      "k1c.constellation.moe" = constellation-only;
      "pinchflat.constellation.moe" = constellation-only;
      "crafty.constellation.moe" = constellation-only;
      "craftydynmap.constellation.moe" = constellation-only;
      "olivetin.constellation.moe" = everyone;
      "threadfin.constellation.moe" = constellation-only;
    };

}
