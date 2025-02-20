{ pkgs, config, lib, ... }:
let
  keys = import ../../misc/ssh-pub-keys.nix;
  ports = import ./misc/service-ports.nix;
  userName = "mediarr";
  userUid = 976;
  groupName = "mediarr";
  groupGid = 972;
  defaultOptions = [
    "--pod=${userName}"
    "--network=container:gluetun"
  ];
  userOptions = [
    "--user=${toString userUid}:${toString groupGid}"
  ];
  allowedPorts = with ports; [
    jellyfin-http
    jellyfin-https
    jellyfin-service-discovery
    jellyfin-client-discovery
    radarr
    sonarr
    lidarr
    readarr
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
    mediarr-openssh
  ];
in {

  # -- Pod Creation --
  systemd.services.podman-create-mediarr-pod = 
  {
    wantedBy = [ "multi-user.target" ];
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
        -p ${toString ports.radarr}:7878 \
        -p ${toString ports.sonarr}:8989 \
        -p ${toString ports.lidarr}:8686 \
        -p ${toString ports.slskd}:5030 \
        -p ${toString ports.slskd-peer}:26156 \
        -p ${toString ports.slskd-peer}:26156/udp \
        -p ${toString ports.readarr}:8787 \
        -p ${toString ports.prowlarr}:9696 \
        -p ${toString ports.bazarr}:6767 \
        -p ${toString ports.jellyseerr}:5055 \
        -p ${toString ports.unpackerr}:${toString ports.unpackerr} \
        -p ${toString ports.qbittorrent-peer}:36494 \
        -p ${toString ports.qbittorrent-peer}:36494/udp \
        -p ${toString ports.qbittorrent-webui}:${toString ports.qbittorrent-webui} \
        -p ${toString ports.tdarr-webui}:8265 \
        -p ${toString ports.tdarr-server}:8266 \
        -p ${toString ports.bitmagnet-webui}:3333 \
        -p ${toString ports.bitmagnet-peer}:3334/tcp \
        -p ${toString ports.bitmagnet-peer}:3334/udp \
        -p ${toString ports.mikochi}:${toString ports.mikochi} \
        -p ${toString ports.cross-seed}:2468 \
        -p ${toString ports.sabnzbd}:${toString ports.sabnzbd} \
        -p ${toString ports.mediarr-openssh}:2222 \
        -p ${toString ports.romm}:8080 \
        -p ${toString ports.neko}:${toString ports.neko} \
        -p ${toString ports.neko-epr-start}-${toString ports.neko-epr-end}:${toString ports.neko-epr-start}-${toString ports.neko-epr-end}/udp \
        --ip "10.88.0.2" \
        --sysctl="net.ipv4.ip_forward=1" \
        --sysctl="net.ipv4.conf.all.src_valid_mark=1" \
        --sysctl="net.ipv4.ping_group_range=0 2000000" \
        --userns=keep-id \
        --shm-size=2g \
        --replace \
        --name=${userName}
    '';
    preStop = ''
      podman pod rm --force --ignore ${userName}
      podman network reload --all
    '';
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
    extraGroups = [ "render" ]; # QSV
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
    "/data/downloads/music".d = rule;
    "/data/downloads/books".d = rule;
    "/data/downloads/games".d = rule;
    "/data/downloads/game-assets".d = rule;
    "/data/downloads/torrents".d = rule;
    "/data/downloads/slskd".d = rule;
    "/data/downloads/cross-seeds".d = rule;
    "/data/downloads/cross-seeds/links".d = rule;
    "/var/lib/${userName}".d = rule;
    "/var/lib/${userName}/radarr".d = rule;
    "/var/lib/${userName}/sonarr".d = rule;
    "/var/lib/${userName}/lidarr".d = rule;
    "/var/lib/${userName}/slskd".d = rule;
    "/var/lib/${userName}/soularr".d = rule;
    "/var/lib/${userName}/readarr".d = rule;
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
    "/var/lib/${userName}/bitmagnet".d = rule;
    "/var/lib/${userName}/gluetun".d = rule;
    "/var/lib/${userName}/cross-seed".d = rule;
    "/var/lib/${userName}/sabnzbd".d = rule;
    "/var/lib/${userName}/sabnzbd/incomplete".d = rule;
    "/var/lib/${userName}/recyclarr".d = rule;
    "/var/lib/${userName}/romm".d = rule;
    "/var/lib/${userName}/romm/redis".d = rule;
    "/var/lib/${userName}/romm/resources".d = rule;
    "/var/lib/${userName}/mariadb".d = rule;
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

  # -- Container Setup --
  virtualisation.oci-containers.containers = {

    jellyfin = {
      image = "lscr.io/linuxserver/jellyfin:latest";
      pull = "newer";
      volumes = [
        "/var/lib/${userName}/jellyfin/config:/config"
        "/var/lib/${userName}/jellyfin/cache:/cache"
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
      ] ++ defaultOptions;
      dependsOn = [ "create-mediarr-pod" "gluetun" ];
    };

    flaresolverr = {
      image = "ghcr.io/flaresolverr/flaresolverr:latest";
      pull = "newer";
      environment = {
        TZ = config.time.timeZone;
        LOG_LEVEL="info";
      };
      extraOptions = [] ++ defaultOptions;
      dependsOn = [ "create-mediarr-pod" "gluetun" ];
    };

    ersatztv = {
      image = "jasongdove/ersatztv:latest-vaapi";
      pull = "newer";
      volumes = [
        "/var/lib/${userName}/ersatztv:/root/.local/share/ersatztv"
        "/data/downloads:/media:ro"
      ];
      environment = {
        TZ = config.time.timeZone;
        PUID = toString userUid;
        PGID = toString groupGid;
      };
      environmentFiles = [ config.sops.secrets.mediarr-iptv-env.path ];
      extraOptions = [
        "--mount" "type=tmpfs,destination=/root/.local/share/etv-transcode"
        "--device=/dev/dri/:/dev/dri/"
      ] ++ defaultOptions;
      dependsOn = [ "create-mediarr-pod" "gluetun" ];
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
      };
      extraOptions = [] ++ defaultOptions;
      dependsOn = [ "create-mediarr-pod" "gluetun" ];
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
      };
      extraOptions = [] ++ defaultOptions;
      dependsOn = [ "create-mediarr-pod" "gluetun" ];
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
      dependsOn = [ "create-mediarr-pod" "gluetun" ];
    };

    slskd = {
      image = "slskd/slskd:latest";
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
      dependsOn = [ "create-mediarr-pod" "gluetun" ];
    };

    soularr = {
      image = "mrusse08/soularr:latest";
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
      dependsOn = [ "create-mediarr-pod" "gluetun" "lidarr" "slskd" ];
    };

    readarr = {
      image = "lscr.io/linuxserver/readarr:develop";
      pull = "newer";
      volumes = [
        "/var/lib/${userName}/readarr:/config"
        "/data/downloads/books:/books"
        "/data/downloads:/downloads"
      ];
      environment = {
        TZ = config.time.timeZone;
        PUID = toString userUid;
        PGID = toString groupGid;
      };
      extraOptions = [] ++ defaultOptions;
      dependsOn = [ "create-mediarr-pod" "gluetun" ];
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
      dependsOn = [ "create-mediarr-pod" "gluetun" ];
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
      dependsOn = [ "create-mediarr-pod" "gluetun" ];
    };

    jellyseerr = {
      image = "fallenbagel/jellyseerr:latest";
      pull = "newer";
      volumes = [
        "/var/lib/${userName}/jellyseerr:/app/config"
      ];
      environment = {
        TZ = config.time.timeZone;
        PUID = toString userUid;
        PGID = toString groupGid;
      };
      extraOptions = [] ++ defaultOptions;
      dependsOn = [ "create-mediarr-pod" "gluetun" ];
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
      dependsOn = [ "create-mediarr-pod" "gluetun" ];
    };

    decluttarr = {
      image = "ghcr.io/manimatter/decluttarr:latest";
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
        RADARR_URL = "http://127.0.0.1:7878";
        SONARR_URL = "http://127.0.0.1:8989";
        LIDARR_URL = "http://127.0.0.1:8686";
        READARR_URL = "http://127.0.0.1:8787";
        QBITTORRENT_URL = "http://127.0.0.1:${toString ports.qbittorrent-webui}";
      };
      environmentFiles = [ config.sops.secrets.mediarr-decluttarr-env.path ];
      extraOptions = [] ++ defaultOptions;
      dependsOn = [ "create-mediarr-pod" "gluetun" "radarr" "sonarr" "lidarr" "readarr" "qbittorrent" ];
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
      ] ++ defaultOptions;
      dependsOn = [ "create-mediarr-pod" "gluetun" ];
    };

    gluetun = {
      image = "qmcgaw/gluetun:latest";
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
      };
      environmentFiles = [ config.sops.secrets.mediarr-gluetun-env.path ];
      extraOptions = [
        "--privileged"
        "--cap-add=NET_ADMIN"
        "--device=/dev/net/tun:/dev/net/tun"
        "--dns=1.1.1.1"
        "--dns=1.0.0.1"
      ] ++ (builtins.filter (e: e != "--network=container:gluetun") defaultOptions);
      dependsOn = [ "create-mediarr-pod" ];
    };

    bitmagnet = {
      image = "ghcr.io/bitmagnet-io/bitmagnet:latest";
      pull = "newer";
      volumes = [
        "/var/lib/${userName}/bitmagnet:/root/.config/bitmagnet"
      ];
      environment = {
        TZ = config.time.timeZone;
        PUID = toString userUid;
        PGID = toString groupGid;
        POSTGRES_HOST = "host.containers.internal";
        POSTGRES_USER = "bitmagnet";
      };
      cmd = [
        "worker"
        "run"
        "--all"
      ];
      extraOptions = [] ++ defaultOptions;
      dependsOn = [ "create-mediarr-pod" "gluetun" ];
    };

    mikochi = {
      image = "zer0tonin/mikochi:latest";
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
      extraOptions = [] ++ defaultOptions ++ userOptions;
      dependsOn = [ "create-mediarr-pod" "gluetun" ];
    };

    unpackerr = {
      image = "golift/unpackerr";
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
        UN_READARR_0_URL = "http://127.0.0.1:8787";
        UN_WEBHOOK_0_TEMPLATE = "discord";
      };
      environmentFiles = [
        config.sops.secrets.mediarr-unpackerr-env.path
      ];
      extraOptions = [] ++ defaultOptions ++ userOptions;
      dependsOn = [ "create-mediarr-pod" "gluetun" "sonarr" "radarr" "lidarr" "readarr" ];
    };

    cross-seed = {
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
      dependsOn = [ "create-mediarr-pod" "gluetun" "prowlarr" "sonarr" "radarr" ];
    };

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
      extraOptions = [] ++ defaultOptions;
      dependsOn = [ "create-mediarr-pod" "gluetun" ];
    };

    # sftp://mediarr@ftp.constellation.moe:2222
    mediarr-openssh = {
      image = "lscr.io/linuxserver/openssh-server:latest";
      pull = "newer";
      volumes = [
        "${builtins.toFile "neith.pub" keys.neith}:/pubkeys/neith.pub"
        "${builtins.toFile "remie.pub" keys.remie}:/pubkeys/remie.pub"
        "${builtins.toFile "vera.pub" keys.vera}:/pubkeys/vera.pub"
        "/var/lib/${userName}:/config"
        "/data/downloads:/downloads"
      ];
      environment = {
        TZ = config.time.timeZone;
        PUID = toString userUid;
        PGID = toString groupGid;
        SUDO_ACCESS = "false";
        PASSWORD_ACCESS = "false";
        USER_NAME = userName;
        PUBLIC_KEY_DIR = "/pubkeys";
      };
      extraOptions = [] ++ defaultOptions;
      dependsOn = [ "create-mediarr-pod" "gluetun" ];
    };

    recyclarr = {
      image = "ghcr.io/recyclarr/recyclarr:latest";
      pull = "newer";
      volumes = [
        "/var/lib/${userName}/recyclarr:/config"
      ];
      environment = {
        TZ = config.time.timeZone;
        PUID = toString userUid;
        PGID = toString groupGid;
        RECYCLARR_CREATE_CONFIG = "true";
        CRON_SCHEDULE = "@daily";
      };
      extraOptions = [] ++ defaultOptions ++ userOptions;
      dependsOn = [ "create-mediarr-pod" "gluetun" "sonarr" "radarr" ];
    };

    romm = {
      image = "rommapp/romm:3.7.0-alpha.1";
      pull = "newer";
      volumes = [
        "/data/downloads/games:/romm/library"
        "/data/downloads/game-assets:/romm/assets"
        "/var/lib/${userName}/romm:/romm/config"
        "/var/lib/${userName}/romm/resources:/romm/resources"
        "/var/lib/${userName}/romm/redis:/redis-data"
      ];
      environment = {
        DB_HOST = "127.0.0.1";
        DB_PORT = "3808";
        DB_NAME = "romm";
      };
      environmentFiles = [ config.sops.secrets.mediarr-romm-env.path ];
      extraOptions = [] ++ defaultOptions ++ userOptions;
      dependsOn = [ "create-mediarr-pod" "gluetun" "mariadb" ];
    };

    mariadb = {
      image = "mariadb:latest";
      pull = "newer";
      volumes = [
        "/var/lib/${userName}/mariadb:/var/lib/mysql"
      ];
      environment = {
        MARIADB_DATABASE = "romm";
      };
      environmentFiles = [ config.sops.secrets.mediarr-mariadb-env.path ];
      cmd = [ "--port" "3808" ];
      extraOptions = [
        "--health-cmd" "CMD"
        "--health-cmd" "healthcheck.sh"
        "--health-cmd='--connect'"
        "--health-cmd='--innodb_initialized'"
        "--health-start-period" "30s"
        "--health-interval" "10s"
      ] ++ defaultOptions ++ userOptions;
      dependsOn = [ "create-mediarr-pod" "gluetun" ];
    };

    neko = {
      image = "ghcr.io/m1k1o/neko/firefox:latest";
      pull = "newer";
      environment = {
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
      ] ++ defaultOptions;
      dependsOn = [ "create-mediarr-pod" "gluetun" ];
    };

  };

  # -- Firewall Setup --
  networking.firewall.interfaces =
  {
    gradientnet.allowedTCPPorts = allowedPorts;
    gradientnet.allowedUDPPorts = allowedPorts;
  };

  networking.firewall.allowedTCPPorts = with ports; [
    mediarr-openssh
    qbittorrent-peer
    slskd-peer
  ];

  networking.firewall.allowedUDPPorts = with ports; [
    qbittorrent-peer
    slskd-peer
  ];

  networking.firewall.allowedUDPPortRanges = [
    {
      from = ports.neko-epr-start;
      to = ports.neko-epr-end;
    }
  ];

}