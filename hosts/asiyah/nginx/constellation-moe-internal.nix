{ config, self, ... }:
let
  ports = import ../misc/service-ports.nix;
in {

  services.nginx.virtualHosts."polycule.constellation.moe" = {
    root = self.inputs.polycule-constellation-moe;
    useACMEHost = "constellation.moe";
    addSSL = true;

    locations."/vdo-ninja/" = {
      proxyPass = "http://127.0.0.1:${toString ports.vdo-ninja}/";
      proxyWebsockets = true;
      extraConfig = ''
        add_header Access-Control-Allow-Origin *;
      '';
    };

    locations."/ersatztv/".extraConfig = ''
      return 302 $scheme://ersatztv.constellation.moe/;
    '';

    locations."/jellyfin".extraConfig = ''
      return 302 $scheme://$host/jellyfin/;
    '';

    locations."/jellyfin/".extraConfig = ''
      return 302 $scheme://jellyfin.constellation.moe/;
    '';
  };

  services.nginx.virtualHosts."jellyfin.constellation.moe" = {
    useACMEHost = "constellation.moe";
    addSSL = true;
    
    extraConfig = ''
      # # https://jellyfin.org/docs/general/networking/nginx/
      ## The default `client_max_body_size` is 1M, this might not be enough for some posters, etc.
      client_max_body_size 20M;
    
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

  services.nginx.virtualHosts."ersatztv.constellation.moe" = {
    useACMEHost = "constellation.moe";
    addSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString ports.ersatztv}";
      proxyWebsockets = true;
    };
  };

  services.nginx.virtualHosts."iptv.constellation.moe" = {
    useACMEHost = "constellation.moe";
    addSSL = true;
    locations."/iptv" = {
      proxyPass = "http://127.0.0.1:${toString ports.ersatztv}/iptv";
      proxyWebsockets = true;
    };
  };

  services.nginx.virtualHosts."jellyseerr.constellation.moe" = {
    useACMEHost = "constellation.moe";
    addSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString ports.jellyseerr}";
      proxyWebsockets = true;
    };
  };

  services.nginx.virtualHosts."radarr.constellation.moe" = {
    useACMEHost = "constellation.moe";
    addSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString ports.radarr}";
      proxyWebsockets = true;
    };
  };

  services.nginx.virtualHosts."sonarr.constellation.moe" = {
    useACMEHost = "constellation.moe";
    addSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString ports.sonarr}";
      proxyWebsockets = true;
    };
  };

  services.nginx.virtualHosts."lidarr.constellation.moe" = {
    useACMEHost = "constellation.moe";
    addSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString ports.lidarr}";
      proxyWebsockets = true;
    };
  };

  services.nginx.virtualHosts."slskd.constellation.moe" = {
    useACMEHost = "constellation.moe";
    addSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString ports.slskd}";
      proxyWebsockets = true;
    };
  };

  services.nginx.virtualHosts."readarr.constellation.moe" = {
    useACMEHost = "constellation.moe";
    addSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString ports.readarr}";
      proxyWebsockets = true;
    };
  };

  services.nginx.virtualHosts."bazarr.constellation.moe" = {
    useACMEHost = "constellation.moe";
    addSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString ports.bazarr}";
      proxyWebsockets = true;
    };
  };

  services.nginx.virtualHosts."prowlarr.constellation.moe" = {
    useACMEHost = "constellation.moe";
    addSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString ports.prowlarr}";
      proxyWebsockets = true;
    };
  };

  services.nginx.virtualHosts."tdarr.constellation.moe" = {
    useACMEHost = "constellation.moe";
    addSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString ports.tdarr-webui}";
      proxyWebsockets = true;
    };
  };

  services.nginx.virtualHosts."torrent.constellation.moe" = {
    useACMEHost = "constellation.moe";
    addSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString ports.qbittorrent-webui}";
      proxyWebsockets = true;
    };
  };

  services.nginx.virtualHosts."bitmagnet.constellation.moe" = {
    useACMEHost = "constellation.moe";
    addSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString ports.bitmagnet-webui}";
      proxyWebsockets = true;
    };
  };

  services.nginx.virtualHosts."sabnzbd.constellation.moe" = {
    useACMEHost = "constellation.moe";
    addSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString ports.sabnzbd}";
      proxyWebsockets = true;
    };
  };

  services.nginx.virtualHosts."romm.constellation.moe" = {
    useACMEHost = "constellation.moe";
    addSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString ports.romm}";
      proxyWebsockets = true;
    };
  };

  services.nginx.virtualHosts."search.constellation.moe" = {
    useACMEHost = "constellation.moe";
    addSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString ports.searx}";
      proxyWebsockets = true;
    };
  };

  services.nginx.virtualHosts."files.constellation.moe" = {
    useACMEHost = "constellation.moe";
    addSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString ports.mikochi}";
      proxyWebsockets = true;
    };
  };

  services.nginx.virtualHosts."neko.constellation.moe" = {
    useACMEHost = "constellation.moe";
    addSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString ports.neko}";
      proxyWebsockets = true;
    };
  };

  services.nginx.virtualHosts."pufferpanel.constellation.moe" = {
    useACMEHost = "constellation.moe";
    addSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString ports.pufferpanel}";
      proxyWebsockets = true;
    };
  };

  # TODO: Figure out a way to automate the below list eugh

  services.oauth2_proxy.nginx.virtualHosts = {
    "polycule.constellation.moe" = {};
    # "jellyfin.constellation.moe" = {}; # Use built-in auth
    "ersatztv.constellation.moe" = {};
    "iptv.constellation.moe" = {};
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
    "pufferpanel.constellation.moe" = {};
  };
  
}