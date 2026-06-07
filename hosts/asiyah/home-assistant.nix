{ config, pkgs, self, lib, ... }:
let
  ports = config.gradient.currentHost.ports;
  localAddresses = config.gradient.const.localAddresses;
  addresses = config.gradient.const.wireguard.addresses.gradientnet;
  pythonPkgs = config.services.home-assistant.package.python.pkgs;
  pkgsCustomComponents = pkgs.master.home-assistant-custom-components;
  pkgsCustomComponentsGradientOS = pkgs.master.home-assistant-custom-components-gradientos;
  pkgsCustomLovelaceModules = pkgs.master.home-assistant-custom-lovelace-modules;
  pkgsCustomLovelaceModulesGradientOS = pkgs.master.home-assistant-custom-lovelace-modules-gradientos;
in
{

  # just temporary I swear!
  disabledModules = [ "services/home-automation/home-assistant.nix" ];
  imports = [ "${toString self.inputs.nixpkgs-master}/nixos/modules/services/home-automation/home-assistant.nix" ];

  services.home-assistant = {
    enable = true;
    package = pkgs.master.home-assistant;
    # TODO: remove, this is temporary to fix something
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
      "folder_watcher"
      "haveibeenpwned"
      "seventeentrack"
      "device_tracker"
      "shell_command"
      "history_stats"
      "shopping_list"
      "utility_meter"
      "python_script"
      "telegram_bot"
      "geo_location"
      "conversation"
      "rest_command"
      "image_upload"
      "media_source"
      "air_quality"
      "nfandroidtv"
      "mobile_app"
      "mcp_server"
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
      "influxdb"
      "logbook"
      "picotts"
      "opensky"
      "history"
      "workday"
      "whisper"
      "wyoming"
      "esphome"
      "brother"
      "ibeacon"
      "holiday"
      "openrgb"
      "webhook"
      "backup"
      "go2rtc"
      "energy"
      "camera"
      "radarr"
      "folder"
      "sonarr"
      "ollama"
      "stream"
      "config"
      "webdav"
      "vacuum"
      "ffmpeg"
      "piper"
      "cloud"
      "html5"
      "onvif"
      "isal"
      "tile"
      "moon"
      "mqtt"
      "waqi"
      "rest"
      "dhcp"
      "ssdp"
      "tuya"
      "ping"
      "cast"
      "met"
      "ipp"
      "zha"
      "sun"
      "usb"
      "ios"
      "mcp"
      "sql"
      "nut"
      "vlc"
      "mpd"
      "tts"
      "my"
    ];
    customComponents = 
      with pkgsCustomComponents;
      with pkgsCustomComponentsGradientOS;
    [
      radarr-upcoming-media
      sonarr-upcoming-media
      mqtt-vacuum-camera
      thermal-comfort
      # google-find-my # TODO: fix...
      anniversaries
      bodymiscale
      # feedparser # TODO: fix
      moonraker
      home-llm
      ingress
      smartir
      frigate
      bermuda
      edata

      #auth_oidc # disable for now, not really that good
      
    ];
    extraPackages = ps: with ps; [ psycopg2 ];

    customLovelaceModules = 
      with pkgsCustomLovelaceModules;
      with pkgsCustomLovelaceModulesGradientOS;
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
        allowlist_external_dirs = [
          "/var/lib/hass"
        ];
        allowlist_external_urls = [
          "https://hass.gradient.moe/"
        ];
        external_url = "https://hass.gradient.moe";
        webrtc.ice_servers = (builtins.map (x: { url = x.urls; }) config.services.go2rtc.settings.webrtc.ice_servers)
          ++ [];
      };

      system_log = {
        fire_event = true;
      };

      zha.zigpy_config.ota.z2m_remote_index = "https://raw.githubusercontent.com/Koenkk/zigbee-OTA/master/index.json";
      lovelace.mode = "storage";
      default_config = {};
      mobile_app = {};
      history = {};
      ffmpeg = {};

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

      sensor = [
        {
          platform = "folder";
          folder = "/var/lib/hass/www/sounds/oucher/";
        }
      ];    

      python_script = {};

      media_player = [ ];

      rest = [
        {
          scan_interval = 60;
          resource = "http://127.0.0.1:${toString ports.llama-cpp}/models";
          sensor = [
            {
              name = "llama-cpp default model";
              json_attributes_path = "$.data.[0]";
              json_attributes = [ "id" "created" "owned_by" ];
              value_template = "{{ value_json.data[0].status.value }}";
            }
          ];
        }
      ];

      rest_command = {
        llama_cpp_load_model = {
          url = "http://127.0.0.1:${toString ports.llama-cpp}/models/load";
          method = "post";
          content_type = "application/json";
          payload = ''{ "model": "{{ model }}" }'';
        };
        llama_cpp_unload_model = {
          url = "http://127.0.0.1:${toString ports.llama-cpp}/models/unload";
          method = "post";
          content_type = "application/json";
          payload = ''{ "model": "{{ model }}" }'';
        };
      };

      shell_command = {
        # Literally SSH into a host with the home assistant private SSH key and run a command
        ssh = "${toString pkgs.openssh}/bin/ssh -i ${config.sops.secrets.hass-ssh-priv.path} -o StrictHostKeyChecking=accept-new {{ host }} {{ command }}";
        # Workaround for a stupid DNS issue I cannot find a proper solution for lol
        dig = "${toString pkgs.dig}/bin/dig {{ host }}";
        curl = "${toString pkgs.curl}/bin/curl {{ args }}";
        systemd_restart = "${toString pkgs.systemd}/bin/systemctl restart {{ unit }}"; # lol lmao
      };

      go2rtc.url = "http://127.0.0.1:${toString ports.frigate-go2rtc}";

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

  users.users.hass.extraGroups = [ "mediarr" "systemd-restart-units"  ];

  systemd.services.home-assistant = {
    wants = [ "postgresql.service" "influxdb2.service" ];
    after = [ "postgresql.service" "influxdb2.service" ];
  };

  networking.firewall.allowedTCPPorts = [ ports.home-assistant ];
  networking.firewall.allowedUDPPorts = [ ports.home-assistant ];

}