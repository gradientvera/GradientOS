{ config, pkgs, ... }:
let
  ports = import ./misc/service-ports.nix;
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
      "private_ble_device"
      "bluetooth_adapters"
      "bluetooth_tracker"
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
      "xiaomi_ble"
      "bluetooth"
      "mqtt_json"
      "mqtt_room"
      "rpi_power"
      "telegram"
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

        propagatedBuildInputs = with pkgs.python312Packages; [
          python-dateutil
          (let
            pname = "e-data";
            version = "1.2.22";
          in pkgs.python312.pkgs.buildPythonPackage {
            inherit pname version;

            src = pkgs.fetchFromGitHub {
              inherit owner;
              repo = "python-edata";
              rev = "v${version}";
              hash = "sha256-h7nqrFKsh97GIebGeIC5E1m1BROTu8ZZ1TrDSO4nFWk=";
            };

            build-system = [
              pkgs.python312Packages.setuptools
            ];

            dependencies = with pkgs.python312Packages; [
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
    ];
    extraPackages = ps: with ps; [ psycopg2 ];
    config.telegram_bot = "!include telegram.yaml";
    config.automation = "!include automations.yaml";
    config.notify = "!include notifiers.yaml";
    config.script = "!include scripts.yaml";
    config.http = {
      server_port = ports.home-assistant;
      use_x_forwarded_for = true;
      trusted_proxies = [ "${addresses.asiyah}" "127.0.0.1" ];
      ip_ban_enabled = true;
      login_attempts_threshold = 10;
    };
    config.lovelace.mode = "storage";
    config.default_config = {};
    config.mobile_app = {};
    config.history = {};
    config.recorder = {
      purge_keep_days = 10;
      db_url = "postgresql://@/hass";
    };
    config.influxdb = {
      api_version = "1";
      host = "127.0.0.1";
      port = toString ports.victoriametrics;
      max_retries = 3;
    };
    config.zha.zigpy_config.ota.z2m_remote_index = "https://raw.githubusercontent.com/Koenkk/zigbee-OTA/master/index.json";
  };

  networking.firewall.interfaces.gradientnet.allowedTCPPorts = [ ports.home-assistant ];
  networking.firewall.interfaces.gradientnet.allowedUDPPorts = [ ports.home-assistant ];

}