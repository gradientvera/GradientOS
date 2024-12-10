{ pkgs, config, lib, ... }:
let
  ports = import ./misc/service-ports.nix;
  userName = "mediarr";
  userUid = 976;
  groupName = "mediarr";
  groupGid = 972;
in {

  # -- Pod Creation --
  systemd.services.podman-create-mediarr-pod = 
  let
    podmanServices = [
      "podman-jellyfin.service"
      "podman-flaresolverr.service"
      "podman-ersatztv.service"
      "podman-radarr.service"
      "podman-sonarr.service"
      "podman-prowlarr.service"
      "podman-bazarr.service"
      "podman-jellyseerr.service"
      "podman-qbittorrent.service"
      "podman-tdarr.service"
      "podman-whisper.service"
      "podman-wireguard.service"
    ];
  in
  {
    wants = podmanServices;
    wantedBy = podmanServices;
    requiredBy = podmanServices;
    before = podmanServices;
    path = [ pkgs.podman ];
    script = ''
      podman pod create \
        -p ${toString ports.jellyfin-http}:8096 \
        -p ${toString ports.jellyfin-https}:8920 \
        -p ${toString ports.jellyfin-client-discovery}:7359/udp \
        -p ${toString ports.jellyfin-service-discovery}:1900/udp \
        -p ${toString ports.flaresolverr}:8191 \
        -p ${toString ports.ersatztv}:8409 \
        -p ${toString ports.radarr}:7878 \
        -p ${toString ports.sonarr}:8989 \
        -p ${toString ports.prowlarr}:9696 \
        -p ${toString ports.bazarr}:6767 \
        -p ${toString ports.jellyseerr}:5055 \
        -p ${toString ports.qbittorrent-peer}:6881 \
        -p ${toString ports.qbittorrent-peer}:6881/udp \
        -p ${toString ports.qbittorrent-webui}:${toString ports.qbittorrent-webui} \
        -p ${toString ports.tdarr-webui}:8265 \
        -p ${toString ports.tdarr-server}:8266 \
        -p ${toString ports.whisper}:9000 \
        --ip 10.88.0.2 \
        --dns 1.1.1.1 \
        --dns 1.0.0.1 \
        --network=podman \
        --sysctl="net.ipv4.conf.all.src_valid_mark=1" \
        --replace \
        --name=mediarr
    '';
    serviceConfig.Type = "oneshot";
  };

  # -- User and Group Setup --
  users.users.${userName} = {
    isSystemUser = true;
    linger = true;
    home = "/var/lib/${userName}";
    createHome = true;
    uid = userUid;
    homeMode = "777";
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
    "/var/lib/${userName}/whisper".d = rule;
    "/var/lib/${userName}/jellyseerr".d = rule;
    "/var/lib/${userName}/qbittorrent".d = rule;
    "/var/lib/${userName}/ersatztv".d = rule;
    "/var/lib/${userName}/jellyfin".d = rule;
    "/var/lib/${userName}/jellyfin/config".d = rule;
    "/var/lib/${userName}/jellyfin/cache".d = rule;
    "/var/lib/${userName}/tdarr/server".d = rule;
    "/var/lib/${userName}/tdarr/config".d = rule;
    "/var/lib/${userName}/tdarr/logs".d = rule;
  };

  # -- Container Setup --
  virtualisation.oci-containers.containers = {

    jellyfin = {
      image = "jellyfin/jellyfin:latest";
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
        "--pod=${userName}"
        "--mount" "type=bind,source=/data/downloads,target=/media"
        "--device=/dev/dri/:/dev/dri/"
      ];
    };

    flaresolverr = {
      image = "ghcr.io/flaresolverr/flaresolverr:latest";
      environment = {
        TZ = config.time.timeZone;
        PUID = toString userUid;
        PGID = toString groupGid;
        LOG_LEVEL="info";
      };
      extraOptions = [
        "--pod=${userName}"
      ];
    };

    ersatztv = {
      image = "jasongdove/ersatztv:develop-vaapi";
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
        "--pod=${userName}"
        "--mount" "type=tmpfs,destination=/root/.local/share/etv-transcode"
        "--device=/dev/dri/:/dev/dri/"
      ];
    };

    radarr = {
      image = "lscr.io/linuxserver/radarr:latest";
      volumes = [
        "/var/lib/${userName}/radarr:/config"
        "/data/downloads:/downloads"
      ];
      environment = {
        TZ = config.time.timeZone;
        PUID = toString userUid;
        PGID = toString groupGid;
      };
      extraOptions = [
        "--pod=${userName}"
      ];
    };

    sonarr = {
      image = "lscr.io/linuxserver/sonarr:latest";
      volumes = [
        "/var/lib/${userName}/sonarr:/config"
        "/data/downloads:/downloads"
      ];
      environment = {
        TZ = config.time.timeZone;
        PUID = toString userUid;
        PGID = toString groupGid;
      };
      extraOptions = [
        "--pod=${userName}"
      ];
    };

    prowlarr = {
      image = "lscr.io/linuxserver/prowlarr:latest";
      volumes = [
        "/var/lib/${userName}/prowlarr:/config"
      ];
      environment = {
        TZ = config.time.timeZone;
        PUID = toString userUid;
        PGID = toString groupGid;
      };
      extraOptions = [
        "--pod=${userName}"
      ];
    };

    bazarr = {
      image = "lscr.io/linuxserver/bazarr:latest";
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
      extraOptions = [
        "--pod=${userName}"
      ];
    };

    jellyseerr = {
      image = "fallenbagel/jellyseerr:latest";
      volumes = [
        "/var/lib/${userName}/jellyseerr:/app/config"
      ];
      environment = {
        TZ = config.time.timeZone;
        PUID = toString userUid;
        PGID = toString groupGid;
      };
      extraOptions = [
        "--pod=${userName}"
      ];
    };

    qbittorrent = {
      image = "lscr.io/linuxserver/qbittorrent:latest";
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
      extraOptions = [
        "--pod=${userName}"
      ];
    };

    tdarr = {
      image = "ghcr.io/haveagitgat/tdarr:latest";
      volumes = [
        "/var/lib/${userName}/tdarr/server:/app/server"
        "/var/lib/${userName}/tdarr/config:/app/configs"
        "/var/lib/${userName}/tdarr/logs:/app/logs"
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
        "--pod=${userName}"
        "--mount" "type=tmpfs,destination=/temp"
        "--device=/dev/dri/:/dev/dri/"
      ];
    };

    whisper = {
      image = "onerahmet/openai-whisper-asr-webservice:latest";
      volumes = [
        "/var/lib/${userName}/whisper:/root/.cache/whisper"
      ];
      environment = {
        TZ = config.time.timeZone;
        PUID = toString userUid;
        PGID = toString groupGid;
        ASR_MODEL = "base";
        ASR_ENGINE = "faster_whisper";
      };
      extraOptions = [
        "--pod=${userName}"
      ];
    };

    wireguard = {
      image = "lscr.io/linuxserver/wireguard:latest";
      volumes = [
        "${config.sops.secrets.mediarr-wireguard.path}:/config/wg_confs/wg0.conf"
      ];
      environment = {
        TZ = config.time.timeZone;
        PUID = toString userUid;
        PGID = toString groupGid;
      };
      extraOptions = [
        "--pod=${userName}"
        "--cap-add=NET_RAW"
        "--cap-add=NET_ADMIN"
        "--cap-add=SYS_MODULE"
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