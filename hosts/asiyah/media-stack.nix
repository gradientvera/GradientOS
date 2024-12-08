{ pkgs, config, lib, ... }:
let
  ports = import ./misc/service-ports.nix;
  userName = "mediarr";
  userUid = 976;
  groupName = "mediarr";
  groupGid = 976;
in {

  # -- User and Group Setup --
  users.users.${userName} = {
    isSystemUser = true;
    linger = true;
    home = "/var/lib/${userName}";
    createHome = true;
    uid = userUid;
    homeMode = "777";
    autoSubUidGidRange = true;
    group = config.users.groups.${groupName}.name;
  };

  users.groups.${groupName} = {
    gid = groupGid;
  };

  # -- Folder and Permissions Setup --
  systemd.tmpfiles.settings."10-media.conf" = let
    rule = {
      user = userName;
      group = groupName;
      mode = "0777";
    };
  in {
    "/data/downloads".d = rule;
    "/data/downloads/tv".d = rule;
    "/data/downloads/movies".d = rule;
    "/var/lib/${userName}".d = rule;
    "/var/lib/${userName}/radarr".d = rule;
    "/var/lib/${userName}/sonarr".d = rule;
    "/var/lib/${userName}/prowlarr".d = rule;
    "/var/lib/${userName}/bazarr".d = rule;
    "/var/lib/${userName}/jellyseerr".d = rule;
    "/var/lib/${userName}/qbittorrent".d = rule;
    "/var/lib/${userName}/ersatztv".d = rule;
    "/var/lib/${userName}/jellyfin".d = rule;
    "/var/lib/${userName}/jellyfin/config".d = rule;
    "/var/lib/${userName}/jellyfin/cache".d = rule;
    "/var/lib/${userName}/tdarr/server".d = rule;
    "/var/lib/${userName}/tdarr/config".d = rule;
    "/var/lib/${userName}/tdarr/logs".d = rule;
    "/var/lib/${userName}/tdarr/cache".d = rule;
  };

  # -- Container Setup --
  virtualisation.oci-containers.containers = {

    jellyfin = {
      image = "jellyfin/jellyfin:latest";
      ports = [
        "${toString ports.jellyfin-http}:8096"
        "${toString ports.jellyfin-https}:8920"
        "${toString ports.jellyfin-client-discovery}:7359/udp"
        "${toString ports.jellyfin-service-discovery}:1900/udp"
      ];
      volumes = [
        "/var/lib/${userName}/jellyfin/config:/config"
        "/var/lib/${userName}/jellyfin/cache:/cache"
        "/data/downloads/tv:/data/tvshows"
        "/data/downloads/movies:/data/movies"
      ];
      environment = {
        TZ = config.time.timeZone;
        PUID = toString userUid;
        PGID = toString groupGid;
      };
      extraOptions = [
        "--mount" "type=bind,source=/data/downloads,target=/media"
        "--device=/dev/dri/:/dev/dri/"
      ];
    };

    flaresolverr = {
      image = "ghcr.io/flaresolverr/flaresolverr:latest";
      ports = [ "${toString ports.flaresolverr}:8191" ];
      environment = {
        TZ = config.time.timeZone;
        PUID = toString userUid;
        PGID = toString groupGid;
        LOG_LEVEL="info";
      };
    };

    ersatztv = {
      image = "jasongdove/ersatztv:latest-vaapi";
      ports = [ "${toString ports.ersatztv}:8409" ];
      volumes = [
        "/var/lib/${userName}/ersatztv:/root/.local/share/ersatztv"
        "/data/downloads:/media:ro"
      ];
      environment = {
        TZ = config.time.timeZone;
        PUID = toString userUid;
        PGID = toString groupGid;
      };
      extraOptions = [
        "--device=/dev/dri/:/dev/dri/"
      ];
    };

    radarr = {
      image = "lscr.io/linuxserver/radarr:latest";
      ports = [ "${toString ports.radarr}:7878" ];
      volumes = [
        "/var/lib/${userName}/radarr:/config"
        "/data/downloads:/downloads"
      ];
      environment = {
        TZ = config.time.timeZone;
        PUID = toString userUid;
        PGID = toString groupGid;
      };
    };

    sonarr = {
      image = "lscr.io/linuxserver/sonarr:latest";
      ports = [ "${toString ports.sonarr}:8989" ];
      volumes = [
        "/var/lib/${userName}/sonarr:/config"
        "/data/downloads:/downloads"
      ];
      environment = {
        TZ = config.time.timeZone;
        PUID = toString userUid;
        PGID = toString groupGid;
      };
    };

    prowlarr = {
      image = "lscr.io/linuxserver/prowlarr:latest";
      ports = [ "${toString ports.prowlarr}:9696" ];
      volumes = [
        "/var/lib/${userName}/prowlarr:/config"
      ];
      environment = {
        TZ = config.time.timeZone;
        PUID = toString userUid;
        PGID = toString groupGid;
      };
    };

    bazarr = {
      image = "lscr.io/linuxserver/bazarr:latest";
      ports = [ "${toString ports.bazarr}:6767" ];
      volumes = [
        "/var/lib/${userName}/bazarr:/config"
        "/data/downloads/movies:/movies"
        "/data/downloads/tv:/tv"
      ];
      environment = {
        TZ = config.time.timeZone;
        PUID = toString userUid;
        PGID = toString groupGid;
        UMASK_SET = "022";
      };
    };

    jellyseerr = {
      image = "fallenbagel/jellyseerr:latest";
      ports = [ "${toString ports.jellyseerr}:5055" ];
      volumes = [
        "/var/lib/${userName}/jellyseerr:/app/config"
      ];
      environment = {
        TZ = config.time.timeZone;
        PUID = toString userUid;
        PGID = toString groupGid;
      };
    };

    qbittorrent = {
      image = "lscr.io/linuxserver/qbittorrent:latest";
      ports = [
        "${toString ports.qbittorrent-peer}:6881"
        "${toString ports.qbittorrent-peer}:6881/udp"
        "${toString ports.qbittorrent-webui}:${toString ports.qbittorrent-webui}"
      ];
      volumes = [
        "/var/lib/${userName}/qbittorrent:/config"
        "/data/downloads:/downloads"
      ];
      environment = {
        TZ = config.time.timeZone;
        PUID = toString userUid;
        PGID = toString groupGid;
        WEBUI_PORT = toString ports.qbittorrent-webui;
      };
    };

    tdarr = {
      image = "ghcr.io/haveagitgat/tdarr:latest";
      ports = [
        "${toString ports.tdarr-webui}:8265"
        "${toString ports.tdarr-server}:8266"
      ];
      volumes = [
        "/var/lib/${userName}/tdarr/server:/app/server"
        "/var/lib/${userName}/tdarr/config:/app/configs"
        "/var/lib/${userName}/tdarr/logs:/app/logs"
        "/var/lib/${userName}/tdarr/cache:/temp"
        "/data/downloads:/media"
      ];
      environment = {
        TZ = config.time.timeZone;
        PUID = toString userUid;
        PGID = toString groupGid;
        serverIP = "0.0.0.0";
        serverPort = toString ports.tdarr-server;
        webUIPort = toString ports.tdarr-webui;
        internalNode = "true";
        inContainer = "true";
        ffmpegVersion = "6";
        nodeName = config.networking.hostName;
      };
      extraOptions = [
        "--device=/dev/dri/:/dev/dri/"
      ];
    };

  };

  # -- Firewall Setup --
  networking.firewall.interfaces.gradientnet.allowedTCPPorts = with ports; [
    jellyfin-http
    jellyfin-https
    jellyfin-service-discovery
    jellyfin-client-discovery
    radarr
    sonarr
    prowlarr
    bazarr
    flaresolverr
    jellyseerr
    tdarr-webui
    tdarr-server
    ersatztv
    qbittorrent-webui
    qbittorrent-peer
  ];
  
  networking.firewall.interfaces.gradientnet.allowedUDPPorts = with ports; [
    qbittorrent-peer
    jellyfin-client-discovery
  ];

  # -- Tor Setup --

  services.tor.client.socksListenAddress = {
    IsolateDestAddr = true;
    addr = "0.0.0.0";
    port = ports.tor;
  };

  networking.firewall.interfaces.podman0.allowedTCPPorts = with ports; [
    tor
  ];

  networking.firewall.interfaces.podman0.allowedUDPPorts = with ports; [
    tor
  ];
}