{ config, self, lib, ... }:
let
  ports = config.gradient.currentHost.ports;
  # TODO: This is copy-pasted... Make this a common lib or something?
  #       or even better, make a NixOS module for it hoooly shit
  mkReverseProxy = { port, address ? "127.0.0.1", protocol ? "http", generateOwnCert ? false,
    rootExtraConfig ? "", vhostExtraConfig ? "", reverseProxyLocation ? "/", reverseProxySubdomain ? "", useACMEHost ? "constellation.moe", extraConfig ? {} }:
  (lib.recursiveUpdate 
  {
    useACMEHost = if (!generateOwnCert) then useACMEHost else null;
    enableACME = generateOwnCert;
    forceSSL = true;
    extraConfig = vhostExtraConfig;
    locations.${reverseProxyLocation} = {
      proxyPass = "${protocol}://${address}:${toString port}${reverseProxySubdomain}";
      proxyWebsockets = true;
      extraConfig = rootExtraConfig;
    };
  } extraConfig);
in {

  services.nginx.virtualHosts."polycule.constellation.moe" = {
    # TODO: Make this an HTML page here, no need for a private repo
    root = self.inputs.polycule-constellation-moe;
    useACMEHost = "constellation.moe";
    forceSSL = true;
  };

  services.nginx.virtualHosts."jellyfin.constellation.moe" = {
    useACMEHost = "constellation.moe";
    addSSL = true;
    
    extraConfig = ''
      # # https://jellyfin.org/docs/general/networking/nginx/
      ## The default `client_max_body_size` is 1M, this might not be enough for some posters, etc.
      client_max_body_size 200M;
    
      # Security / XSS Mitigation Headers
      # NOTE: X-Frame-Options may cause issues with the webOS app
      # add_header X-Frame-Options "SAMEORIGIN";
      # add_header X-Content-Type-Options "nosniff";

      # Permissions policy. May cause issues with some clients
      # add_header Permissions-Policy "accelerometer=(), ambient-light-sensor=(), battery=(), bluetooth=(), camera=(), clipboard-read=(), display-capture=(), document-domain=(), encrypted-media=(), gamepad=(), geolocation=(), gyroscope=(), hid=(), idle-detection=(), interest-cohort=(), keyboard-map=(), local-fonts=(), magnetometer=(), microphone=(), payment=(), publickey-credentials-get=(), serial=(), sync-xhr=(), usb=(), xr-spatial-tracking=()" always;

      # Content Security Policy
      # See: https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP
      # Enforces https content and restricts JS/CSS to origin
      # External Javascript (such as cast_sender.js for Chromecast) must be whitelisted.
      # NOTE: The default CSP headers may cause issues with the webOS app
      # add_header Content-Security-Policy "default-src https: data: blob: ; img-src 'self' https://* ; style-src 'self' 'unsafe-inline'; script-src 'self' 'unsafe-inline' https://www.gstatic.com https://www.youtube.com blob:; worker-src 'self' blob:; connect-src 'self'; object-src 'none'; frame-ancestors 'self'";
    '';

    locations."/".extraConfig = ''
      # https://jellyfin.org/docs/general/networking/nginx/
      # Proxy main Jellyfin traffic
      proxy_pass http://127.0.0.1:${toString ports.jellyfin-http};
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
      proxy_set_header X-Forwarded-Protocol $scheme;
      proxy_set_header X-Forwarded-Host $http_host;

      # Disable buffering when the nginx proxy gets very resource heavy upon streaming
      proxy_buffering off;
    '';

    locations."/socket".extraConfig = ''
      # https://jellyfin.org/docs/general/networking/nginx/
      # Proxy Jellyfin Websockets traffic
      proxy_pass http://127.0.0.1:${toString ports.jellyfin-http};
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
    "ersatztv.constellation.moe" = mkReverseProxy { port = ports.ersatztv; rootExtraConfig = "proxy_buffering off;"; };
    "iptv.constellation.moe" = mkReverseProxy { port = ports.ersatztv; reverseProxyLocation = "/iptv"; reverseProxySubdomain = "/iptv"; rootExtraConfig = "proxy_buffering off;"; };
    "jellyseerr.constellation.moe" = mkReverseProxy { port = ports.jellyseerr; };
    "radarr.constellation.moe" = mkReverseProxy { port = ports.radarr; };
    "sonarr.constellation.moe" = mkReverseProxy { port = ports.sonarr; };
    "lidarr.constellation.moe" = mkReverseProxy { port = ports.lidarr; };
    "slskd.constellation.moe" = mkReverseProxy { port = ports.slskd; };
    "readarr.constellation.moe" = mkReverseProxy { port = ports.readarr; };
    "bazarr.constellation.moe" = mkReverseProxy { port = ports.bazarr; };
    "prowlarr.constellation.moe" = mkReverseProxy { port = ports.prowlarr; };
    "tdarr.constellation.moe" = mkReverseProxy { port = ports.tdarr-webui; };
    "torrent.constellation.moe" = mkReverseProxy { port = ports.qbittorrent-webui; };
    "bitmagnet.constellation.moe" = mkReverseProxy { port = ports.bitmagnet-webui; };
    "sabnzbd.constellation.moe" = mkReverseProxy { port = ports.sabnzbd; };
    "romm.constellation.moe" = mkReverseProxy { port = ports.romm; };
    "search.constellation.moe" = mkReverseProxy { port = ports.searx; };
    "files.constellation.moe" = mkReverseProxy { port = ports.mikochi; };
    "neko.constellation.moe" = mkReverseProxy { port = ports.neko; };
    "calibre.constellation.moe" = mkReverseProxy {
      port = ports.calibre-web-automated;
      vhostExtraConfig = ''
        client_max_body_size 4G;
        proxy_buffer_size 128k;
        proxy_buffers 4 256k;
        proxy_busy_buffers_size 256k;
        auth_request_set $username $upstream_http_x_auth_request_preferred_username;
      
      '';
      rootExtraConfig = ''
        proxy_set_header X-Forwarded-Preferred-Username $xusername;
        proxy_pass_header X-Forwarded-Preferred-Username;
      '';
      extraConfig.locations."/kobo".extraConfig = ''
        auth_request off;
        proxy_pass http://127.0.0.1:${toString ports.calibre-web-automated};
      '';
    };
    "calibredl.constellation.moe" = mkReverseProxy { port = ports.calibre-downloader; };
    "radio.constellation.moe" = mkReverseProxy { port = ports.openwebrx; };
    "nextcloud.constellation.moe" = { useACMEHost = "constellation.moe"; forceSSL = true; };
    "k1c.constellation.moe" = mkReverseProxy { address = "192.168.1.27"; port = 80; };
  };

  # TODO: Figure out a way to automate the below list eugh
  services.oauth2-proxy.nginx.virtualHosts = {
    "polycule.constellation.moe" = {};
    # "jellyfin.constellation.moe" = {}; # Use built-in auth
    "ersatztv.constellation.moe" = {};
    # "iptv.constellation.moe" = {}; # Use built-in auth
    # "jellyseerr.constellation.moe" = {}; # Use built-in auth
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
    "romm.constellation.moe" = {};
    "search.constellation.moe" = {};
    "files.constellation.moe" = {};
    "neko.constellation.moe" = {};
    "calibre.constellation.moe" = {};
    "calibredl.constellation.moe" = {};
    "radio.constellation.moe" = {};
    "k1c.constellation.moe" = {};
  };
  
}