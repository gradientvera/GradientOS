{ config, pkgs, lib, ... }:
let
  ports = config.gradient.currentHost.ports;
  addresses = config.gradient.const.wireguard.addresses.gradientnet;
in
{

  services.home-assistant = {
    enable = true;
    lovelaceConfigWritable = true;
    extraComponents = [
      "homeassistant_alerts"
      "bluetooth_le_tracker"
      "pvpc_hourly_pricing"
      #"private_ble_device" # Build failure
      "bluetooth_adapters"
      #"bluetooth_tracker" # Build failure
      "mqtt_eventstream"
      "mqtt_statestream"
      "androidtv_remote"
      "assist_pipeline"
      "default_config"
      "haveibeenpwned"
      "python_script"
      "shell_command"
      "history_stats"
      "shopping_list"
      "utility_meter"
      "telegram_bot"
      "raspberry_pi"
      "geo_location"
      "conversation"
      "image_upload"
      "media_source"
      "air_quality"
      "nfandroidtv"
      "mobile_app"
      #"xiaomi_ble" # Build failure
      "bluetooth"
      "mqtt_json"
      "mqtt_room"
      "rpi_power"
      "telegram"
      "fail2ban"
      "recorder"
      "zeroconf"
      "apple_tv"
      "logbook"
      "history"
      "workday"
      "esphome"
      "brother"
      "ibeacon"
      "holiday"
      "webhook"
      "backup"
      "energy"
      "camera"
      "stream"
      "config"
      "cloud"
      "moon"
      "mqtt"
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
      "my"
    ];
    customComponents = with pkgs.home-assistant-custom-components; [
      moonraker

      #auth_oidc # disable for now, not really that good

      (let
        owner = "uvejota";
        version = "2024.07.6";
      in pkgs.buildHomeAssistantComponent {
        inherit version owner;
        domain = "edata";

        src = pkgs.fetchFromGitHub {
          inherit owner;
          repo = "homeassistant-edata";
          rev = version;
          hash = "sha256-HGCjwYf5aLFUMuh4InAjLZHHIU6aidjoAQuhH9W+pkw=";
        };

        propagatedBuildInputs = [
          pkgs.python313Packages.python-dateutil
          (let
            pname = "e-data";
            version = "1.2.22";
          in pkgs.python313.pkgs.buildPythonPackage {
            inherit pname version;

            src = pkgs.fetchFromGitHub {
              inherit owner;
              repo = "python-edata";
              rev = "v${version}";
              hash = "sha256-h7nqrFKsh97GIebGeIC5E1m1BROTu8ZZ1TrDSO4nFWk=";
            };

            build-system = [
              pkgs.python313Packages.setuptools
            ];

            dependencies = with pkgs.python313Packages; [
              dateparser
              freezegun
              holidays
              pytest
              python-dateutil
              requests
              voluptuous
              jinja2
            ];
          })
        ];
      })

      (let
        owner = "openrgb-ha";
        version = "2.7.0";
      in pkgs.buildHomeAssistantComponent {
        inherit version owner;
        domain = "openrgb";

        src = pkgs.fetchFromGitHub {
          inherit owner;
          repo = "openrgb-ha";
          rev = "v${version}";
          hash = "sha256-cTOkTyOU3aBXIGU1FL1boKU/6RIeFMC8yKc+0wcTVUU=";
        };

        propagatedBuildInputs = [
          pkgs.python313Packages.openrgb-python
        ];
      })

    ];
    extraPackages = ps: with ps; [ psycopg2 ];

    config = {
      # Imports/includes
      telegram_bot = "!include telegram.yaml";
      automation = "!include automations.yaml";
      notify = "!include notifiers.yaml";
      script = "!include scripts.yaml";

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

    };

  };

  networking.firewall.interfaces.gradientnet.allowedTCPPorts = [ ports.home-assistant ];
  networking.firewall.interfaces.gradientnet.allowedUDPPorts = [ ports.home-assistant ];

}