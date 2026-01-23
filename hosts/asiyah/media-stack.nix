{ pkgs, config, lib, ... }:
let
  ports = config.gradient.currentHost.ports;
  userName = "mediarr";
  userUid = 976;
  groupName = "mediarr";
  groupGid = 972;
  podOptions = [
    "--pod=${userName}"
  ];
  gluetunOptions = [
    "--network=container:gluetun"
  ];
  defaultOptions = podOptions ++ gluetunOptions;
  userOptions = [
    "--user=${toString userUid}:${toString groupGid}"
  ];
  allowedPorts = with ports; [
    jellyfin-http
    jellyfin-https
    jellyfin-service-discovery
    jellyfin-client-discovery
    radarr
    radarr-es
    sonarr
    sonarr-es
    lidarr
    prowlarr
    bazarr
    flaresolverr
    jellyseerr
    unpackerr
    tdarr-webui
    tdarr-server
    ersatztv
    qbittorrent-webui
    qbittorrent-peer
    mikochi
    cross-seed
    sabnzbd
    neko
    proxy-vpn
    proxy-vpn-uk
    profilarr
    calibre-web-automated
    calibre-downloader
  ];
in {

  # -- Pod Creation --
  systemd.services.podman-create-mediarr-pod = rec
  {
    wantedBy = [ "multi-user.target" ];
    requiredBy = [
      "podman-jellyfin.service"
      "podman-flaresolverr.service"
      "podman-ersatztv.service"
      "podman-radarr.service"
      "podman-sonarr.service"
      "podman-radarr-es.service"
      "podman-sonarr-es.service"
      "podman-lidarr.service"
      "podman-slskd.service"
      "podman-soularr.service"
      "podman-prowlarr.service"
      "podman-bazarr.service"
      "podman-jellyseerr.service"
      "podman-qbittorrent.service"
      "podman-decluttarr.service"
      "podman-tdarr.service"
      "podman-gluetun.service"
      "podman-proxy-vpn-socks5.service"
      "podman-mikochi.service"
      "podman-unpackerr.service"
      # "podman-cross-seed.service"
      "podman-sabnzbd.service"
      "podman-profilarr.service"
      "podman-romm.service"
      "podman-mariadb.service"
      # "podman-neko.service"
      "podman-calibre-downloader.service"

    ];
    before = requiredBy;
    wants = [ "postgresql.service" "network-online.target" ];
    after = [ "postgresql.service" "network-online.target" ];
    path = [ pkgs.podman ];
    # Static IP is needed because changing published ports and recreating the pod
    # will NOT clear the old NAT rules, because podman fucking sucks.
    script = ''
      podman pod create \
        -p ${toString ports.jellyfin-http}:8096 \
        -p ${toString ports.jellyfin-https}:8920 \
        -p ${toString ports.jellyfin-client-discovery}:7359/udp \
        -p ${toString ports.jellyfin-service-discovery}:1900/udp \
        -p ${toString ports.flaresolverr}:8191 \
        -p ${toString ports.ersatztv}:8409 \
        -p ${toString ports.radarr}:${toString ports.radarr} \
        -p ${toString ports.sonarr}:${toString ports.sonarr} \
        -p ${toString ports.radarr-es}:${toString ports.radarr-es} \
        -p ${toString ports.sonarr-es}:${toString ports.sonarr-es} \
        -p ${toString ports.lidarr}:8686 \
        -p ${toString ports.slskd}:5030 \
        -p ${toString ports.slskd-peer}:26156 \
        -p ${toString ports.slskd-peer}:26156/udp \
        -p ${toString ports.prowlarr}:9696 \
        -p ${toString ports.profilarr}:6868 \
        -p ${toString ports.bazarr}:6767 \
        -p ${toString ports.jellyseerr}:5055 \
        -p ${toString ports.unpackerr}:${toString ports.unpackerr} \
        -p ${toString ports.qbittorrent-peer}:36494 \
        -p ${toString ports.qbittorrent-peer}:36494/udp \
        -p ${toString ports.qbittorrent-webui}:${toString ports.qbittorrent-webui} \
        -p ${toString ports.tdarr-webui}:8265 \
        -p ${toString ports.tdarr-server}:8266 \
        -p ${toString ports.mikochi}:${toString ports.mikochi} \
        -p ${toString ports.cross-seed}:2468 \
        -p ${toString ports.sabnzbd}:${toString ports.sabnzbd} \
        -p ${toString ports.romm}:8080 \
        -p ${toString ports.proxy-vpn}:${toString ports.proxy-vpn} \
        -p ${toString ports.calibre-downloader}:${toString ports.calibre-downloader} \
        -p ${toString ports.pinchflat}:8945 \
        --ip "10.88.0.2" \
        --sysctl="net.ipv4.ip_forward=1" \
        --sysctl="net.ipv4.conf.all.src_valid_mark=1" \
        --sysctl="net.ipv4.ping_group_range=0 2000000" \
        --label io.containers.autoupdate=registry \
        --label PODMAN_SYSTEMD_UNIT=podman-create-mediarr-pod.service \
        --userns=keep-id \
        --shm-size=2g \
        --replace \
        --name=${userName}
    '';
    # -p ${toString ports.neko}:${toString ports.neko} \
    # -p ${toString ports.neko-epr-start}-${toString ports.neko-epr-end}:${toString ports.neko-epr-start}-${toString ports.neko-epr-end}/udp \
    preStop = ''
      podman pod rm --force --ignore ${userName}
      podman network reload --all
    '';
    serviceConfig.Environment = "PODMAN_SYSTEMD_UNIT=podman-create-mediarr-pod.service";
    serviceConfig.Type = "oneshot";
    serviceConfig.RemainAfterExit = "yes";
  };

  networking.firewall.logRefusedPackets = true;

  # -- User and Group Setup --
  users.users.${userName} = {
    isSystemUser = true;
    linger = true;
    home = "/var/lib/${userName}";
    createHome = true;
    uid = userUid;
    homeMode = "775";
    group = config.users.groups.${groupName}.name;
    extraGroups = [ "video" "render" ]; # QSV
  };

  users.groups.${groupName} = {
    gid = groupGid;
  };

  # -- Folder and Permissions Setup --
  systemd.tmpfiles.settings."10-media.conf" = let
    rule = {
      user = userName;
      group = groupName;
      mode = "0775";
    };
  in {
    "/data/downloads".d = rule;
    "/data/downloads/tv".d = rule;
    "/data/downloads/movies".d = rule;
    "/data/downloads/tv-es".d = rule;
    "/data/downloads/movies-es".d = rule;
    "/data/downloads/adverts".d = rule;
    "/data/downloads/youtube".d = rule;
    "/data/downloads/music".d = rule;
    "/data/downloads/books".d = rule;
    "/data/downloads/books-ingest".d = rule;
    "/data/downloads/games".d = rule;
    "/data/downloads/game-assets".d = rule;
    "/data/downloads/torrents".d = rule;
    "/data/downloads/slskd".d = rule;
    "/data/downloads/cross-seeds".d = rule;
    "/data/downloads/cross-seeds/links".d = rule;
    "/var/lib/${userName}".d = rule;
    "/var/lib/${userName}/radarr".d = rule;
    "/var/lib/${userName}/radarr-es".d = rule;
    "/var/lib/${userName}/sonarr".d = rule;
    "/var/lib/${userName}/sonarr-es".d = rule;
    "/var/lib/${userName}/lidarr".d = rule;
    "/var/lib/${userName}/slskd".d = rule;
    "/var/lib/${userName}/soularr".d = rule;
    "/var/lib/${userName}/prowlarr".d = rule;
    "/var/lib/${userName}/bazarr".d = rule;
    "/var/lib/${userName}/whisper".d = rule;
    "/var/lib/${userName}/jellyseerr".d = rule;
    "/var/lib/${userName}/unpackerr".d = rule;
    "/var/lib/${userName}/qbittorrent".d = rule;
    "/var/lib/${userName}/qbittorrent/incomplete".d = rule;
    "/var/lib/${userName}/ersatztv".d = rule;
    "/var/lib/${userName}/jellyfin".d = rule;
    "/var/lib/${userName}/jellyfin/config".d = rule;
    "/var/lib/${userName}/jellyfin/cache".d = rule;
    "/var/lib/${userName}/tdarr/server".d = rule;
    "/var/lib/${userName}/tdarr/config".d = rule;
    "/var/lib/${userName}/tdarr/logs".d = rule;
    "/var/lib/${userName}/tdarr/temp".d = rule;
    "/var/lib/${userName}/gluetun".d = rule;
    "/var/lib/${userName}/gluetun-uk".d = rule;
    "/var/lib/${userName}/cross-seed".d = rule;
    "/var/lib/${userName}/sabnzbd".d = rule;
    "/var/lib/${userName}/sabnzbd/incomplete".d = rule;
    "/var/lib/${userName}/profilarr".d = rule;
    "/var/lib/${userName}/romm".d = rule;
    "/var/lib/${userName}/romm/redis".d = rule;
    "/var/lib/${userName}/romm/resources".d = rule;
    "/var/lib/${userName}/mariadb".d = rule;
    "/var/lib/${userName}/calibre-web-automated".d = rule;
    "/var/lib/${userName}/pinchflat".d = rule;
    "/var/lib/${userName}/.mozilla".d = rule;
    "/var/lib/${userName}/.mozilla/firefox".d = rule;
    "/var/lib/${userName}/modcache".d = rule;
  };

  services.clamav.scanner.scanDirectories = [ "/data/downloads" ]; # /var/lib already scanned by default

  # -- ROM sync --
  gradient.profiles.gaming.emulation = {
    enable = true;
    installEmulators = false;
    user = userName;
    group = groupName;
    sync.enable = true;
    romPath = "/data/downloads/games/roms";
  };

  gradient.presets.syncthing.extraGroups = [ "mediarr" "users" ];

  # -- Container Setup --
  virtualisation.oci-containers.containers = {

    jellyfin = {
      image = "lscr.io/linuxserver/jellyfin:latest";
      pull = "newer";
      volumes = [
        "/var/lib/${userName}/jellyfin/config:/config"
        "/var/lib/${userName}/jellyfin/cache:/cache"
        "/var/lib/${userName}/modcache:/modcache"
      ];
      environment = {
        TZ = config.time.timeZone;
        PUID = toString userUid;
        PGID = toString groupGid;
        DOCKER_MODS="linuxserver/mods:jellyfin-opencl-intel";
      };
      extraOptions = [
        "--mount" "type=bind,source=/data/downloads,target=/media"
        "--device=/dev/dri/:/dev/dri/"
      ] ++ podOptions;
      labels = {
        "io.containers.autoupdate" = "registry";
        "PODMAN_SYSTEMD_UNIT" = "podman-jellyfin.service";
      };
      dependsOn = [ ];
    };

    flaresolverr = {
      image = "ghcr.io/flaresolverr/flaresolverr:latest";
      pull = "newer";
      environment = {
        TZ = config.time.timeZone;
        LOG_LEVEL="info";
      };
      extraOptions = [] ++ defaultOptions;
      labels = {
        "io.containers.autoupdate" = "registry";
        "PODMAN_SYSTEMD_UNIT" = "podman-flaresolverr.service";
      };
      dependsOn = [ "gluetun" ];
    };

    ersatztv = {
      image = "ghcr.io/ersatztv/ersatztv:latest";
      pull = "newer";
      volumes = [
        "/var/lib/${userName}/ersatztv:/root/.local/share/ersatztv"
      ];
      environment = {
        TZ = config.time.timeZone;
        PUID = toString userUid;
        PGID = toString groupGid;
      };
      environmentFiles = [ config.sops.secrets.mediarr-iptv-env.path ];
      extraOptions = [
        "--mount" "type=bind,source=/data/downloads,target=/media"
        "--mount" "type=tmpfs,destination=/transcode"
        "--device=/dev/dri/:/dev/dri/"
      ] ++ podOptions;
      labels = {
        "io.containers.autoupdate" = "registry";
        "PODMAN_SYSTEMD_UNIT" = "podman-ersatztv.service";
      };
      dependsOn = [ ];
    };

    radarr = {
      image = "lscr.io/linuxserver/radarr:latest";
      pull = "newer";
      volumes = [
        "/var/lib/${userName}/radarr:/config"
        "/data/downloads:/downloads"
      ];
      environment = {
        TZ = config.time.timeZone;
        PUID = toString userUid;
        PGID = toString groupGid;
        RADARR__SERVER__PORT = toString ports.radarr;
      };
      extraOptions = [] ++ defaultOptions;
      labels = {
        "io.containers.autoupdate" = "registry";
        "PODMAN_SYSTEMD_UNIT" = "podman-radarr.service";
      };
      dependsOn = [ "gluetun" ];
    };

    sonarr = {
      image = "lscr.io/linuxserver/sonarr:latest";
      pull = "newer";
      volumes = [
        "/var/lib/${userName}/sonarr:/config"
        "/data/downloads:/downloads"
      ];
      environment = {
        TZ = config.time.timeZone;
        PUID = toString userUid;
        PGID = toString groupGid;
        SONARR__SERVER__PORT = toString ports.sonarr;
      };
      extraOptions = [] ++ defaultOptions;
      labels = {
        "io.containers.autoupdate" = "registry";
        "PODMAN_SYSTEMD_UNIT" = "podman-sonarr.service";
      };
      dependsOn = [ "gluetun" ];
    };

    radarr-es = {
      image = "lscr.io/linuxserver/radarr:latest";
      pull = "newer";
      volumes = [
        "/var/lib/${userName}/radarr-es:/config"
        "/data/downloads:/downloads"
      ];
      environment = {
        TZ = config.time.timeZone;
        PUID = toString userUid;
        PGID = toString groupGid;
        RADARR__SERVER__PORT = toString ports.radarr-es;
      };
      extraOptions = [] ++ defaultOptions;
      labels = {
        "io.containers.autoupdate" = "registry";
        "PODMAN_SYSTEMD_UNIT" = "podman-radarr-es.service";
      };
      dependsOn = [ "gluetun" ];
    };

    sonarr-es = {
      image = "lscr.io/linuxserver/sonarr:latest";
      pull = "newer";
      volumes = [
        "/var/lib/${userName}/sonarr-es:/config"
        "/data/downloads:/downloads"
      ];
      environment = {
        TZ = config.time.timeZone;
        PUID = toString userUid;
        PGID = toString groupGid;
        SONARR__SERVER__PORT = toString ports.sonarr-es;
      };
      extraOptions = [] ++ defaultOptions;
      labels = {
        "io.containers.autoupdate" = "registry";
        "PODMAN_SYSTEMD_UNIT" = "podman-sonarr-es.service";
      };
      dependsOn = [ "gluetun" ];
    };

    lidarr = {
      image = "lscr.io/linuxserver/lidarr:latest";
      pull = "newer";
      volumes = [
        "/var/lib/${userName}/lidarr:/config"
        "/data/downloads/music:/music"
        "/data/downloads:/downloads"
      ];
      environment = {
        TZ = config.time.timeZone;
        PUID = toString userUid;
        PGID = toString groupGid;
      };
      extraOptions = [] ++ defaultOptions;
      labels = {
        "io.containers.autoupdate" = "registry";
        "PODMAN_SYSTEMD_UNIT" = "podman-lidarr.service";
      };
      dependsOn = [ "gluetun" ];
    };

    slskd = {
      image = "docker.io/slskd/slskd:latest";
      pull = "newer";
      volumes = [
        "/var/lib/${userName}/slskd:/app"
        "/data/downloads:/downloads"
      ];
      environment = {
        TZ = config.time.timeZone;
        PUID = toString userUid;
        PGID = toString groupGid;
        SLSKD_REMOTE_CONFIGURATION = "true";
      };  
      extraOptions = [] ++ defaultOptions ++ userOptions;
      labels = {
        "io.containers.autoupdate" = "registry";
        "PODMAN_SYSTEMD_UNIT" = "podman-slskd.service";
      };
      dependsOn = [ "gluetun" ];
    };

    soularr = {
      image = "docker.io/mrusse08/soularr:latest";
      pull = "newer";
      volumes = [
        "/var/lib/${userName}/soularr:/data"
        "/data/downloads:/downloads"
      ];
      environment = {
        TZ = config.time.timeZone;
        PUID = toString userUid;
        PGID = toString groupGid;
        SCRIPT_INTERVAL = "300";
      };  
      extraOptions = [] ++ defaultOptions ++ userOptions;
      labels = {
        "io.containers.autoupdate" = "registry";
        "PODMAN_SYSTEMD_UNIT" = "podman-soularr.service";
      };
      dependsOn = [ "gluetun" "lidarr" "slskd" ];
    };

    prowlarr = {
      image = "lscr.io/linuxserver/prowlarr:latest";
      pull = "newer";
      volumes = [
        "/var/lib/${userName}/prowlarr:/config"
      ];
      environment = {
        TZ = config.time.timeZone;
        PUID = toString userUid;
        PGID = toString groupGid;
      };
      extraOptions = [] ++ defaultOptions;
      labels = {
        "io.containers.autoupdate" = "registry";
        "PODMAN_SYSTEMD_UNIT" = "podman-prowlarr.service";
      };
      dependsOn = [ "gluetun" ];
    };

    bazarr = {
      image = "lscr.io/linuxserver/bazarr:latest";
      pull = "newer";
      volumes = [
        "/var/lib/${userName}/bazarr:/config"
        "/data/downloads/movies:/movies"
        "/data/downloads/tv:/tv"
      ];
      environment = {
        TZ = config.time.timeZone;
        PUID = toString userUid;
        PGID = toString groupGid;
      };
      extraOptions = [] ++ defaultOptions;
      labels = {
        "io.containers.autoupdate" = "registry";
        "PODMAN_SYSTEMD_UNIT" = "podman-bazarr.service";
      };
      dependsOn = [ "gluetun" ];
    };

    jellyseerr = {
      image = "docker.io/fallenbagel/jellyseerr:latest";
      pull = "newer";
      volumes = [
        "/var/lib/${userName}/jellyseerr:/app/config"
      ];
      environment = {
        TZ = config.time.timeZone;
        PUID = toString userUid;
        PGID = toString groupGid;
      };
      extraOptions = [] ++ podOptions;
      labels = {
        "io.containers.autoupdate" = "registry";
        "PODMAN_SYSTEMD_UNIT" = "podman-jellyseerr.service";
      };
      dependsOn = [ ];
    };

    qbittorrent = {
      image = "lscr.io/linuxserver/qbittorrent:latest";
      pull = "newer";
      volumes = [
        "${config.sops.secrets.mediarr-qbittorrent-script.path}:/notify.sh"
        "/var/lib/${userName}/qbittorrent:/config"
        "/data/downloads:/downloads"
      ];
      environment = {
        TZ = config.time.timeZone;
        PUID = toString userUid;
        PGID = toString groupGid;
        WEBUI_PORT = toString ports.qbittorrent-webui;
      };
      extraOptions = [] ++ defaultOptions;
      labels = {
        "io.containers.autoupdate" = "registry";
        "PODMAN_SYSTEMD_UNIT" = "podman-qbittorrent.service";
      };
      dependsOn = [ "gluetun" ];
    };

    decluttarr = {
      # v2 has a *lot* of breaking changes! can't be bothered to upgrade
      image = "ghcr.io/manimatter/decluttarr:v1.50.2";
      pull = "newer";
      environment = {
        TZ = config.time.timeZone;
        PUID = toString userUid;
        PGID = toString groupGid;
        LOG_LEVEL = "INFO";
        REMOVE_TIMER = "10";
        REMOVE_FAILED = "True";
        REMOVE_FAILED_IMPORTS = "True";
        REMOVE_METADATA_MISSING = "True";
        REMOVE_MISSING_FILES = "True";
        REMOVE_ORPHANS = "True";
        REMOVE_SLOW = "True";
        REMOVE_STALLED = "True";
        REMOVE_UNMONITORED = "True";
        RUN_PERIODIC_RESCANS = ''
          {
          "SONARR": {"MISSING": true, "CUTOFF_UNMET": true, "MAX_CONCURRENT_SCANS": 3, "MIN_DAYS_BEFORE_RESCAN": 7},
          "RADARR": {"MISSING": true, "CUTOFF_UNMET": true, "MAX_CONCURRENT_SCANS": 3, "MIN_DAYS_BEFORE_RESCAN": 7}
          }
        '';
        PERMITTED_ATTEMPTS = "3";
        NO_STALLED_REMOVAL_QBIT_TAG = "Don't Kill";
        MIN_DOWNLOAD_SPEED = "100";
        FAILED_IMPORT_MESSAGE_PATTERNS = ''
          [
          "Not a Custom Format upgrade for existing",
          "Not an upgrade for existing"
          ]
        '';
        RADARR_URL = "http://radarr:7878";
        SONARR_URL = "http://sonarr:8989";
        LIDARR_URL = "http://lidarr:8686";
        QBITTORRENT_URL = "http://qbittorrent:${toString ports.qbittorrent-webui}";
      };
      environmentFiles = [ config.sops.secrets.mediarr-decluttarr-env.path ];
      extraOptions = [] ++ podOptions;
      labels = {
        "io.containers.autoupdate" = "registry";
        "PODMAN_SYSTEMD_UNIT" = "podman-decluttarr.service";
      };
      dependsOn = [ "radarr" "sonarr" "lidarr" "qbittorrent" ];
    };

    tdarr = {
      image = "ghcr.io/haveagitgat/tdarr:latest";
      pull = "newer";
      volumes = [
        "${config.sops.secrets.mediarr-custom-axios.path}:/app/Tdarr_Server/node_modules/axios/lib/core/Axios.js:ro"
        "/var/lib/${userName}/tdarr/server:/app/server"
        "/var/lib/${userName}/tdarr/config:/app/configs"
        "/var/lib/${userName}/tdarr/logs:/app/logs"
        "/var/lib/${userName}/tdarr/temp:/temp"
        "/data/downloads/tv:/media/tv"
        "/data/downloads/movies:/media/movies"
        "/data/downloads/adverts:/media/adverts"
        "/data/downloads/youtube:/media/youtube"
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
        ffmpegVersion = "7";
        auth = "false"; # OAuth2 proxy handles this
        nodeName = config.networking.hostName;
      };
      extraOptions = [
        "--device=/dev/dri/:/dev/dri/"
      ] ++ podOptions;
      labels = {
        "io.containers.autoupdate" = "registry";
        "PODMAN_SYSTEMD_UNIT" = "podman-tdarr.service";
      };
      dependsOn = [ ];
    };

    gluetun = {
      image = "docker.io/qmcgaw/gluetun:latest";
      pull = "newer";
      volumes = [
        "/var/lib/${userName}/gluetun:/gluetun"
      ];
      environment = {
        TZ = config.time.timeZone;
        PUID = toString userUid;
        PGID = toString groupGid;
        VPN_SERVICE_PROVIDER = "airvpn";
        VPN_TYPE = "wireguard";
        FIREWALL_INPUT_PORTS = builtins.concatStringsSep "," (builtins.map (p: toString p) allowedPorts);
        FIREWALL_VPN_INPUT_PORTS = "${toString ports.qbittorrent-peer},${toString ports.slskd-peer}";
        FIREWALL_OUTBOUND_SUBNETS="10.88.0.0/24";
        WIREGUARD_MTU = "1320";
        WIREGUARD_PERSISTENT_KEEPALIVE_INTERVAL = "15s";
      };
      environmentFiles = [ config.sops.secrets.mediarr-gluetun-env.path ];
      extraOptions = [
        "--privileged"
        "--cap-add=NET_ADMIN"
        "--dns=1.1.1.1"
        "--dns=1.0.0.1"
      ] ++ (builtins.filter (e: e != "--network=container:gluetun") defaultOptions);
      labels = {
        "io.containers.autoupdate" = "registry";
        "PODMAN_SYSTEMD_UNIT" = "podman-gluetun.service";
      };
      dependsOn = [ ];
    };

    # TODO: Replace with https://github.com/ynuwenhof/koblas
    proxy-vpn-socks5 = {
      image = "docker.io/serjs/go-socks5-proxy:latest";
      pull = "newer";
      environment = {
        REQUIRE_AUTH = "false";
        PROXY_PORT = toString ports.proxy-vpn;
      };
      extraOptions = [] ++ defaultOptions;
      labels = {
        "io.containers.autoupdate" = "registry";
        "PODMAN_SYSTEMD_UNIT" = "podman-proxy-vpn-socks5.service";
      };
      dependsOn = [ "gluetun" ];
    };

    gluetun-uk = {
      image = "docker.io/qmcgaw/gluetun:latest";
      pull = "newer";
      volumes = [
        "/var/lib/${userName}/gluetun-uk:/gluetun"
      ];
      ports = [
        # Ports for things connected to this VPN go here
        "${toString ports.proxy-vpn-uk}:${toString ports.proxy-vpn-uk}"
      ];
      environment = {
        TZ = config.time.timeZone;
        PUID = toString userUid;
        PGID = toString groupGid;
        VPN_SERVICE_PROVIDER = "airvpn";
        VPN_TYPE = "wireguard";
        FIREWALL_INPUT_PORTS = builtins.concatStringsSep "," (builtins.map (p: toString p) allowedPorts);
        FIREWALL_VPN_INPUT_PORTS = "";
        FIREWALL_OUTBOUND_SUBNETS="10.88.0.0/24";
        WIREGUARD_MTU = "1320";
        WIREGUARD_PERSISTENT_KEEPALIVE_INTERVAL = "15s";
        HTTP_CONTROL_SERVER_ADDRESS = "127.0.0.1:8001";
        HEALTH_SERVER_ADDRESS = "127.0.0.1:9998";
      };
      environmentFiles = [ config.sops.secrets.mediarr-gluetun-uk-env.path ];
      extraOptions = [
        "--ip" "10.88.0.5"
        "--privileged"
        "--cap-add=NET_ADMIN"
        "--dns=1.1.1.1"
        "--dns=1.0.0.1"
      ];
      labels = {
        "io.containers.autoupdate" = "registry";
        "PODMAN_SYSTEMD_UNIT" = "podman-gluetun-uk.service";
      };
      dependsOn = [ ];
    };

    proxy-vpn-uk-socks5 = {
      image = "docker.io/serjs/go-socks5-proxy:latest";
      pull = "newer";
      environment = {
        REQUIRE_AUTH = "false";
        PROXY_PORT = toString ports.proxy-vpn-uk;
      };
      extraOptions = [ "--network=container:gluetun-uk" ];
      labels = {
        "io.containers.autoupdate" = "registry";
        "PODMAN_SYSTEMD_UNIT" = "podman-proxy-vpn-uk-socks5.service";
      };
      dependsOn = [ "gluetun-uk" ];
    };

    mikochi = {
      image = "docker.io/zer0tonin/mikochi:latest";
      pull = "newer";
      volumes = [
        "/data/downloads:/data"
      ];
      environment = {
        TZ = config.time.timeZone;
        PUID = toString userUid;
        PGID = toString groupGid;
        HOST = "0.0.0.0:${toString ports.mikochi}";
        NO_AUTH = "true";
        GZIP = "true";
      };
      extraOptions = [] ++ podOptions ++ userOptions;
      labels = {
        "io.containers.autoupdate" = "registry";
        "PODMAN_SYSTEMD_UNIT" = "podman-mikochi.service";
      };
      dependsOn = [ ];
    };

    unpackerr = {
      image = "docker.io/golift/unpackerr";
      pull = "newer";
      volumes = [
        "/var/lib/${userName}/unpackerr:/config"
        "/data/downloads:/downloads"
      ];
      environment = {
        TZ = config.time.timeZone;
        PUID = toString userUid;
        PGID = toString groupGid;
        UN_LOG_FILE = "/downloads/unpackerr.log";
        UN_FILE_MODE = "0775";
        UN_DIR_MODE = "0775";
        UN_WEBSERVER_METRICS = "true";
        UN_WEBSERVER_LISTEN_ADDR = "0.0.0.0:${toString ports.unpackerr}";
        UN_SONARR_0_URL = "http://127.0.0.1:8989";
        UN_RADARR_0_URL = "http://127.0.0.1:7878";
        UN_LIDARR_0_URL = "http://127.0.0.1:8686";
        UN_WEBHOOK_0_TEMPLATE = "discord";
      };
      environmentFiles = [
        config.sops.secrets.mediarr-unpackerr-env.path
      ];
      extraOptions = [] ++ podOptions ++ userOptions;
      labels = {
        "io.containers.autoupdate" = "registry";
        "PODMAN_SYSTEMD_UNIT" = "podman-unpackerr.service";
      };
      dependsOn = [ "sonarr" "radarr" "lidarr" ];
    };

    # TODO: Broken! Fix sometime
    /*cross-seed = {
      image = "ghcr.io/cross-seed/cross-seed:6";
      pull = "newer";
      volumes = [
        "/var/lib/${userName}/cross-seed:/config"
        "/data/downloads:/downloads:ro"
        "/data/downloads/torrents:/torrents:ro"
        "/data/downloads/cross-seeds:/cross-seeds"
      ];
      environment = {
        TZ = config.time.timeZone;
        PUID = toString userUid;
        PGID = toString groupGid;

      };
      cmd = [ "daemon" ];
      extraOptions = [] ++ defaultOptions ++ userOptions;
      labels = {
        "io.containers.autoupdate" = "registry";
        "PODMAN_SYSTEMD_UNIT" = "podman-cross-seed.service";
      };
      dependsOn = [ "gluetun" "prowlarr" "sonarr" "radarr" ];
    };*/

    sabnzbd = {
      image = "lscr.io/linuxserver/sabnzbd:latest";
      pull = "newer";
      volumes = [
        "/var/lib/${userName}/sabnzbd:/config"
        "/var/lib/${userName}/sabnzbd/incomplete:/incomplete-downloads"
        "/data/downloads:/downloads"
      ];
      environment = {
        TZ = config.time.timeZone;
        PUID = toString userUid;
        PGID = toString groupGid;
      };
      extraOptions = [] ++ podOptions;
      labels = {
        "io.containers.autoupdate" = "registry";
        "PODMAN_SYSTEMD_UNIT" = "podman-sabnzbd.service";
      };
      dependsOn = [ ];
    };

    profilarr = {
      image = "docker.io/santiagosayshey/profilarr:latest";
      pull = "newer";
      volumes = [
        "/var/lib/${userName}/profilarr:/config"
      ];
      environment = {
        TZ = config.time.timeZone;
      };
      extraOptions = [] ++ podOptions;
      labels = {
        "io.containers.autoupdate" = "registry";
        "PODMAN_SYSTEMD_UNIT" = "podman-profilarr.service";
      };
      dependsOn = [ "sonarr" "radarr" ];
    };

    romm = {
      image = "docker.io/rommapp/romm:latest";
      pull = "newer";
      volumes = [
        "/data/downloads/games:/romm/library"
        "/data/downloads/game-assets:/romm/assets"
        "/var/lib/${userName}/romm:/romm/config"
        "/var/lib/${userName}/romm/resources:/romm/resources"
        "/var/lib/${userName}/romm/redis:/redis-data"
      ];
      environment = {
        TZ = config.time.timeZone;
        DB_HOST = "127.0.0.1";
        DB_PORT = "3808";
        DB_NAME = "romm";
      };
      environmentFiles = [ config.sops.secrets.mediarr-romm-env.path ];
      extraOptions = [] ++ podOptions ++ userOptions;
      labels = {
        "io.containers.autoupdate" = "registry";
        "PODMAN_SYSTEMD_UNIT" = "podman-romm.service";
      };
      dependsOn = [ "mariadb" ];
    };

    mariadb = {
      image = "docker.io/mariadb:latest";
      pull = "newer";
      volumes = [
        "/var/lib/${userName}/mariadb:/var/lib/mysql"
      ];
      environment = {
        TZ = config.time.timeZone;
        MARIADB_DATABASE = "romm";
      };
      environmentFiles = [ config.sops.secrets.mediarr-mariadb-env.path ];
      cmd = [ "--port" "3808" ];
      extraOptions = [
        # TODO: Broken! Fix sometime...
        /*"--health-cmd" "CMD"
        "--health-cmd" "healthcheck.sh"
        "--health-cmd='--connect'"
        "--health-cmd='--innodb_initialized'"
        "--health-start-period" "30s"
        "--health-interval" "10s"*/
      ] ++ podOptions ++ userOptions;
      labels = {
        "io.containers.autoupdate" = "registry";
        "PODMAN_SYSTEMD_UNIT" = "podman-mariadb.service";
      };
      dependsOn = [ ];
    };

    /*
    neko = {
      image = "ghcr.io/m1k1o/neko/firefox:latest";
      pull = "newer";
      volumes = [
        "/var/lib/${userName}/.mozilla:/home/neko/.mozilla"
      ];
      environment = {
        TZ = config.time.timeZone;
        NEKO_SCREEN = "1920x1080@30";
        NEKO_BIND = ":${toString ports.neko}";
        NEKO_EPR = "${toString ports.neko-epr-start}-${toString ports.neko-epr-end}";
        NEKO_UDPMUX = "${toString ports.neko-epr-start}";
        NEKO_PROXY = "true";
        NEKO_IPFETCH = "https://checkip.amazonaws.com";
        NEKO_CORS = "127.0.0.1 neko.constellation.moe"; 
        NEKO_ICESERVER = "stun:stun.l.google.com:19302";
        NEKO_IMPLICIT_CONTROL = "true";
        NEKO_CONTROL_PROTECTION = "true";
      };
      environmentFiles = [ config.sops.secrets.mediarr-neko-env.path ];
      extraOptions = [
        "--device=/dev/dri/:/dev/dri/"
      ] ++ podOptions;
      labels = {
        "io.containers.autoupdate" = "registry";
        "PODMAN_SYSTEMD_UNIT" = "podman-neko.service";
      };
      dependsOn = [ ];
    };
    */

    calibre = {
      image = "docker.io/crocodilestick/calibre-web-automated:latest";
      pull = "newer";
      ports = [ "${toString ports.calibre-web-automated}:8083" ];
      volumes = [
        "/var/lib/${userName}/calibre-web-automated:/config"
        "/data/downloads/books:/calibre-library"
        "/data/downloads/books-ingest:/cwa-book-ingest"
        "${(toString (pkgs.writeText "convert_library.py" (builtins.readFile ./cwa-convert_library-fixed.py)))}:/app/calibre-web-automated/scripts/convert_library.py"
      ];
      environment = {
        TZ = config.time.timeZone;
        PUID = toString userUid;
        PGID = toString groupGid;
      };
      extraOptions = [
        "--ip=10.88.0.7"
      ];
      labels = {
        "io.containers.autoupdate" = "registry";
        "PODMAN_SYSTEMD_UNIT" = "podman-calibre.service";
      };
    };

    calibre-downloader = {
      image = "ghcr.io/calibrain/calibre-web-automated-book-downloader:latest";
      pull = "newer";
      volumes = [
        "/data/downloads/books-ingest:/ingest"
      ];
      environment = {
        FLASK_PORT = toString ports.calibre-downloader;
        FLASK_DEBUG = "false";
        BOOK_LANGUAGE = "en";
        INGEST_DIR = "/ingest";
        TZ = config.time.timeZone;
        UID = toString userUid;
        GID = toString groupGid;
      };
      extraOptions = [] ++ defaultOptions;
      labels = {
        "io.containers.autoupdate" = "registry";
        "PODMAN_SYSTEMD_UNIT" = "podman-calibre-downloader.service";
      };
      dependsOn = [ "gluetun" ];
    };

    pinchflat = {
      image = "ghcr.io/kieraneglin/pinchflat:latest";
      pull = "newer";
      volumes = [
        "/var/lib/${userName}/pinchflat:/config"
        "/data/downloads/youtube:/downloads"
        # For existing downloads
        "/data/downloads/youtube:/data/downloads/youtube"
      ];
      environmentFiles = [ config.sops.secrets.pinchflat.path ];
      environment = {
        TZ = config.time.timeZone;
        YT_DLP_WORKER_CONCURRENCY = "1";
      };
      extraOptions = [] ++ defaultOptions;
      labels = {
        "io.containers.autoupdate" = "registry";
        "PODMAN_SYSTEMD_UNIT" = "podman-pinchflat.service";
      };
      dependsOn = [ "gluetun" ];
    };

  };

  # -- Firewall Setup --
  networking.firewall.interfaces =
  {
    gradientnet.allowedTCPPorts = allowedPorts;
    gradientnet.allowedUDPPorts = allowedPorts;
  };

  networking.firewall.allowedUDPPorts = with ports; [
    qbittorrent-peer
  ];

  networking.firewall.allowedUDPPortRanges = [
    {
      from = ports.neko-epr-start;
      to = ports.neko-epr-end;
    }
  ];

}