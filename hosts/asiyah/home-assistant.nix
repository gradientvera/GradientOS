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
      "mikrotik"
      "telegram"
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
      # feedparser # TODO: fix
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
      automation = "!include automations.yaml";
      notify = "!include notifiers.yaml";
      script = "!include scripts.yaml";

      homeassistant = {
        media_dirs = {
          media = "/var/lib/hass/media";
          music = "/data/downloads/music";
          tv = "/data/downloads/tv";
          movies = "/data/downloads/movies";
          youtube = "/data/downloads/youtube";
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

  users.users.hass.extraGroups = [ "mediarr" ];
  
  systemd.services.home-assistant = {
    wants = [ "postgresql.service" "influxdb2.service" ];
    after = [ "postgresql.service" "influxdb2.service" ];
  };

  networking.firewall.allowedTCPPorts = [ ports.home-assistant ];
  networking.firewall.allowedUDPPorts = [ ports.home-assistant ];

}