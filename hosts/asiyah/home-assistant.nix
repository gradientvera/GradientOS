{ config, pkgs, lib, ... }:
let
  ports = config.gradient.currentHost.ports;
  localAddresses = config.gradient.const.localAddresses;
  addresses = config.gradient.const.wireguard.addresses.gradientnet;
  pythonPkgs = config.services.home-assistant.package.python.pkgs;
in
{

  services.home-assistant = {
    enable = true;
    lovelaceConfigWritable = true;
    extraComponents = [
      "homeassistant_alerts"
      "bluetooth_le_tracker"
      "pvpc_hourly_pricing"
      "private_ble_device"
      "bluetooth_adapters"
      "bluetooth_tracker"
      "device_automation"
      "mqtt_eventstream"
      "mqtt_statestream"
      "androidtv_remote"
      "assist_pipeline"
      "speedtestdotnet"
      "remote_calendar"
      "default_config"
      "haveibeenpwned"
      "seventeentrack"
      "device_tracker"
      "python_script"
      "shell_command"
      "history_stats"
      "shopping_list"
      "utility_meter"
      "telegram_bot"
      "geo_location"
      "conversation"
      "image_upload"
      "media_source"
      "air_quality"
      "nfandroidtv"
      "mobile_app"
      "vlc_telnet"
      "xiaomi_ble"
      "bluetooth"
      "mqtt_json"
      "mqtt_room"
      "rpi_power"
      "switchbot"
      "telegram"
      "fail2ban"
      "recorder"
      "zeroconf"
      "apple_tv"
      "logbook"
      "history"
      "workday"
      "whisper"
      "wyoming"
      "esphome"
      "brother"
      "ibeacon"
      "holiday"
      "webhook"
      "backup"
      "energy"
      "camera"
      "radarr"
      "sonarr"
      "ollama"
      "stream"
      "config"
      "webdav"
      "vacuum"
      "piper"
      "cloud"
      "html5"
      "isal"
      "tile"
      "moon"
      "mqtt"
      "waqi"
      "dhcp"
      "ssdp"
      "tuya"
      "cast"
      "met"
      "ipp"
      "zha"
      "sun"
      "usb"
      "ios"
      "sql"
      "nut"
      "vlc"
      "mpd"
      "my"
    ];
    customComponents = 
      with pkgs.home-assistant-custom-components;
      with pkgs.home-assistant-custom-components-gradientos;
    [
      radarr-upcoming-media
      sonarr-upcoming-media
      mqtt-vacuum-camera
      thermal-comfort
      anniversaries
      hass-ingress
      openrgb-ha
      feedparser
      moonraker
      smartir
      bermuda
      edata

      #auth_oidc # disable for now, not really that good
      
    ];
    extraPackages = ps: with ps; [ psycopg2 ];

    customLovelaceModules = 
      with pkgs.home-assistant-custom-lovelace-modules;
      with pkgs.home-assistant-custom-lovelace-modules-gradientos;
    [
      zigbee2mqtt-networkmap
      xiaomi-vacuum-map-card
      atomic-calendar-revive
      advanced-camera-card
      decluttering-card
      valetudo-map-card
      mini-graph-card
      # custom-sidebar
      # auto-entities
      sankey-chart
      vacuum-card
      bubble-card
      mushroom
      card-mod
    ];

    config = {
      # Imports/includes
      telegram_bot = "!include telegram.yaml";
      automation = "!include automations.yaml";
      notify = "!include notifiers.yaml";
      script = "!include scripts.yaml";

      homeassistant = {
        media_dirs = {
          media = "/var/lib/hass/media";
          music = "/data/downloads/music";
          tv = "/data/downloads/tv";
          movies = "/data/downloads/movies";
          adverts = "/data/downloads/adverts";
        };
      };

      zha.zigpy_config.ota.z2m_remote_index = "https://raw.githubusercontent.com/Koenkk/zigbee-OTA/master/index.json";
      lovelace.mode = "storage";
      default_config = {};
      mobile_app = {};
      history = {};

      http = {
        server_port = ports.home-assistant;
        use_x_forwarded_for = true;
        trusted_proxies = [ "${addresses.asiyah}" "127.0.0.1" ];
        ip_ban_enabled = true;
        login_attempts_threshold = 10;
      };

      recorder = {
        purge_keep_days = 10;
        db_url = "postgresql://@/hass";
      };

      influxdb = {
        api_version = "1";
        host = "127.0.0.1";
        port = toString ports.victoriametrics;
        max_retries = 3;
      };

      sensor = [
        {
          platform = "fail2ban";
          # Actually get all jails that are configured
          jails = (lib.map (x: x.name) (lib.attrsToList config.services.fail2ban.jails));
        }
      ];

      shell_command = {
        # Literally SSH into a host with the home assistant private SSH key and run a command
        ssh = "${toString pkgs.openssh}/bin/ssh -i ${config.sops.secrets.hass-ssh-priv.path} {{ host }} {{ command }}";
      };

      ingress = {
        # Slugs need to use underscore, dashes are not allowed
        robot_vacuums = {
          work_mode = "custom";
          url = "/files/ingress/ha-tabs-ingress.js";
          title = "Robot Vacuums";
          icon = "mdi:robot-vacuum";
        };
        angela = {
          parent = "robot_vacuums";
          title = "Angela";
          icon = "mdi:home-floor-1";
          work_mode = "ingress";
          url = localAddresses.vacuum-angela;
        };
        mute = {
          parent = "robot_vacuums";
          title = "*Mute";
          icon = "mdi:home-floor-0";
          work_mode = "ingress";
          url = localAddresses.vacuum-mute;
        };
        printer_k1c = {
          title = "3D Printer K1C";
          icon = "mdi:printer-3d-nozzle";
          work_mode = "ingress";
          url = localAddresses.printer-k1c;
          ui_mode = "toolbar";
        };
        zigbee2mqtt = {
          title = "Zigbee2MQTT";
          icon = "mdi:zigbee";
          work_mode = "ingress";
          url = "127.0.0.1:${toString ports.zigbee2mqtt}";
          ui_mode = "toolbar";
        };
        esphome = {
          title = "ESPHome";
          icon = "mdi:chip";
          work_mode = "ingress";
          url = "127.0.0.1:${toString ports.esphome}";
          ui_mode = "toolbar";
        };
      };

    };

  };

  # Media player support, local mpd support
  # gradient.profiles.audio.enable = true;
  users.users.hass.extraGroups = [ "audio" ];

  hardware.alsa = {
    enable = true;
    enablePersistence = true;
    config = ''
pcm.!default {
    type asym
    playback.pcm "btspeaker"
}


pcm.btspeaker {
        type plug
        slave.pcm {
                type bluealsa
                device "11:75:58:21:AA:F7"
                profile "a2dp"
        }
        hint {
                show on
                description "Bluetooth Speaker"
        }
}
    '';
  };

  services.mopidy = {
    enable = true;
    extensionPackages = [
      pkgs.mopidy-mpd
      pkgs.mopidy-local
    ];
    configuration = ''
      [mpd]
      hostname = ::

      [audio]
      output = alsasink

      [file]
      enabled = true
      media_dirs =
          /var/lib/mopidy/media
      show_dotfiles = false
      excluded_file_extensions =
        .directory
        .html
        .jpeg
        .jpg
        .log
        .nfo
        .pdf
        .png
        .txt
        .zip
      follow_symlinks = false
      metadata_timeout = 1000

      [http]
      enabled = false

      [stream]
      enabled = true
      protocols =
          http
          https
          mms
          rtmp
          rtmps
          rtsp

      [softwaremixer]
      enabled = true
    '';
  };

  services.dbus.packages = [ pkgs.bluez-alsa ];
  systemd.services.bluealsa = {
    wantedBy = [ "bluetooth.target" ];
    requires = [ "bluetooth.service" ];
    requisite = [ "dbus.service" ];
    after = [ "bluetooth.service" ];
    serviceConfig = {
      Type = "dbus";
      BusName = "org.bluealsa";
      Restart = "on-failure";
      User = "root";
      ExecStart = "${pkgs.bluez-alsa}/bin/bluealsa -S --device=hci0 -p a2dp-source -p a2dp-sink";
      ReadWritePaths = "/var/lib/bluealsa";
      StateDirectory = "bluealsa";
      AmbientCapabilities = "CAP_NET_RAW";
      CapabilityBoundingSet = "CAP_NET_RAW";
      IPAddressDeny = "any";
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      NoNewPrivileges = true;
      PrivateDevices = true;
      PrivateTmp = true;
      PrivateUsers = false;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "invisible";
      ProtectSystem = "strict";
      RemoveIPC = true;
      RestrictAddressFamilies = "AF_UNIX AF_BLUETOOTH";
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
      SystemCallErrorNumber = "EPERM";
      UMask = 0077;
    };
  };

  networking.firewall.allowedTCPPorts = [ ports.home-assistant ];
  networking.firewall.allowedUDPPorts = [ ports.home-assistant ];

}