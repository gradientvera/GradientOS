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
    mediarr-openssh
  ];
in {

  # -- Pod Creation --
  systemd.services.podman-create-mediarr-pod = 
  {
    wantedBy = [ "multi-user.target" ];
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
        -p ${toString ports.lidarr}:8686 \
        -p ${toString ports.readarr}:8787 \
        -p ${toString ports.prowlarr}:9696 \
        -p ${toString ports.bazarr}:6767 \
        -p ${toString ports.bazarr-embedded}:6768 \
        -p ${toString ports.jellyseerr}:5055 \
        -p ${toString ports.unpackerr}:${toString ports.unpackerr} \
        -p ${toString ports.qbittorrent-peer}:6881 \
        -p ${toString ports.qbittorrent-peer}:6881/udp \
        -p ${toString ports.qbittorrent-webui}:${toString ports.qbittorrent-webui} \
        -p ${toString ports.tdarr-webui}:8265 \
        -p ${toString ports.tdarr-server}:8266 \
        -p ${toString ports.whisper}:9000 \
        -p ${toString ports.bitmagnet-webui}:3333 \
        -p ${toString ports.bitmagnet-peer}:3334/tcp \
        -p ${toString ports.bitmagnet-peer}:3334/udp \
        -p ${toString ports.mikochi}:${toString ports.mikochi} \
        -p ${toString ports.cross-seed}:2468 \
        -p ${toString ports.sabnzbd}:8080 \
        -p ${toString ports.mediarr-openssh}:2222 \
        --sysctl="net.ipv4.ip_forward=1" \
        --sysctl="net.ipv4.conf.all.src_valid_mark=1" \
        --userns=keep-id \
        --replace \
        --name=${userName}
    '';
    serviceConfig.Type = "oneshot";
    serviceConfig.RemainAfterExit = "yes";
  };

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
    "/data/downloads/torrents".d = rule;
    "/data/downloads/cross-seeds".d = rule;
    "/data/downloads/sabnzbd-incomplete".d = rule;
    "/var/lib/${userName}".d = rule;
    "/var/lib/${userName}/radarr".d = rule;
    "/var/lib/${userName}/sonarr".d = rule;
    "/var/lib/${userName}/lidarr".d = rule;
    "/var/lib/${userName}/readarr".d = rule;
    "/var/lib/${userName}/prowlarr".d = rule;
    "/var/lib/${userName}/bazarr".d = rule;
    "/var/lib/${userName}/bazarr-embedded".d = rule;
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
    "/var/lib/${userName}/postgres".d = rule;
    "/var/lib/${userName}/gluetun".d = rule;
    "/var/lib/${userName}/cross-seed".d = rule;
    "/var/lib/${userName}/sabnzbd".d = rule;
    "/var/lib/${userName}/sabnzbd/incomplete".d = rule;
    "/var/lib/${userName}/recyclarr".d = rule;
  };

  services.clamav.scanner.scanDirectories = [ "/data/downloads" ]; # /var/lib already scanned by default

  # -- Container Setup --
  virtualisation.oci-containers.containers = {

    jellyfin = {
      image = "lscr.io/linuxserver/jellyfin:latest";
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
      environment = {
        TZ = config.time.timeZone;
        LOG_LEVEL="info";
      };
      extraOptions = [] ++ defaultOptions;
      dependsOn = [ "create-mediarr-pod" "gluetun" ];
    };

    ersatztv = {
      image = "jasongdove/ersatztv:latest-vaapi";
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

    readarr = {
      image = "lscr.io/linuxserver/readarr:develop";
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

    bazarr-embedded = {
      image = "lscr.io/linuxserver/bazarr:latest";
      volumes = [
        "/var/lib/${userName}/bazarr-embedded:/config"
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
      extraOptions = [] ++ defaultOptions;
      dependsOn = [ "create-mediarr-pod" "gluetun" ];
    };

    gluetun = {
      image = "qmcgaw/gluetun:latest";
      volumes = [
        "/var/lib/${userName}/gluetun:/gluetun"
      ];
      environment = {
        TZ = config.time.timeZone;
        PUID = toString userUid;
        PGID = toString groupGid;
        VPN_SERVICE_PROVIDER = "mullvad";
        VPN_TYPE = "wireguard";
        SERVER_CITIES = "Amsterdam, Paris, Denmark, Helsinki, Berlin, Zurich, London";
        OWNED_ONLY = "yes";
        FIREWALL_INPUT_PORTS = builtins.concatStringsSep "," (builtins.map (p: toString p) allowedPorts);
        FIREWALL_OUTBOUND_SUBNETS="192.168.24.0/24,10.88.0.0/24";
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
      volumes = [
        "/var/lib/${userName}/bitmagnet:/root/.config/bitmagnet"
      ];
      environment = {
        TZ = config.time.timeZone;
        PUID = toString userUid;
        PGID = toString groupGid;
        POSTGRES_HOST="127.0.0.1";
      };
      environmentFiles = [ config.sops.secrets.mediarr-postgres-env.path ];
      cmd = [
        "worker"
        "run"
        "--all"
      ];
      extraOptions = [] ++ defaultOptions;
      dependsOn = [ "create-mediarr-pod" "gluetun" "postgres" ];
    };

    postgres = {
      image = "postgres:16-alpine";
      volumes = [
        "/var/lib/${userName}/postgres:/var/lib/postgresql/data"
      ];
      environment = {
        TZ = config.time.timeZone;
        PUID = toString userUid;
        PGID = toString groupGid;
        POSTGRES_DB = "bitmagnet";
      };
      environmentFiles = [ config.sops.secrets.mediarr-postgres-env.path ];
      extraOptions = [
        "--shm-size" "1g"
        "--health-cmd" "CMD-SHELL"
        "--health-cmd" "pg_isready"
        "--health-cmd" "pg_isready"
        "--health-start-period" "20s"
        "--health-interval" "10s"
      ] ++ defaultOptions ++ userOptions;
      dependsOn = [ "create-mediarr-pod" "gluetun" ];
    };

    mikochi = {
      image = "zer0tonin/mikochi:latest";
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
      volumes = [
        "/var/lib/${userName}/cross-seed:/config"
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
      dependsOn = [ "create-mediarr-pod" "gluetun" ];
    };

    sabnzbd = {
      image = "lscr.io/linuxserver/sabnzbd:latest";
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
      volumes = [
        "${builtins.toFile "neith.pub" keys.neith}:/pubkeys/neith.pub"
        # TODO: "${builtins.toFile "neith.pub" keys.remie}:/pubkeys/remie.pub"
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

  };

  # -- Firewall Setup --
  networking.firewall.interfaces =
  {
    gradientnet.allowedTCPPorts = allowedPorts;
    gradientnet.allowedUDPPorts = allowedPorts;
  };

  networking.firewall.allowedTCPPorts = with ports; [
    mediarr-openssh
  ];
}