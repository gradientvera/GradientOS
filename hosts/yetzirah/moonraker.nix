{ config, pkgs, self, ... }:
let
  ports = config.gradient.currentHost.ports;
  addresses = config.gradient.const.wireguard.addresses;
  hostName = config.networking.hostName;
  kamp = self.inputs.klipper-adaptive-meshing-purging;
  cfgPath = "/var/lib/moonraker";
in {

  services.moonraker = {
    enable = true;
    stateDir = cfgPath;
    allowSystemControl = true;
    address = "0.0.0.0";
    port = ports.moonraker;
    settings = {

      octoprint_compat = {
        enable_ufp = "True";
        webcam_enabled = "True";
        stream_url = "/stream";
      };

      history = { };

      authorization = {
        cors_domains = [
          "*://127.0.0.1:*"
          "*://${config.networking.hostName}:*"
          "*://${addresses.gradientnet.${hostName}}:*"
          "*://${addresses.lilynet.${hostName}}:*"
          "*//mainsail.${hostName}.constellation.moe"
          "*//mainsail.${hostName}.gradient.moe"
          "*//${hostName}.gradient"
          "*//${hostName}.lily"
        ];
        trusted_clients = [
          "127.0.0.1"
          "${addresses.gradientnet.gradientnet}/24"
          "${addresses.lilynet.lilynet}/24"
        ];
      };

      file_manager = {
        check_klipper_config_path = "False";
        enable_object_processing = "True";
      };

      # Enable ustreamer camera support.
      "webcam c920" = {
        enabled = "True";
        service = "uv4l-mjpeg";
        stream_url = "/stream";
        snapshot_url = "/snapshot";
        aspect_ratio = "16:9";
        location = "printer";
        icon = "printer";
        target_fps = 30;
        target_fps_idle = 15;
      };

      "webcam endoscope" = {
        enabled = "True";
        service = "uv4l-mjpeg";
        stream_url = "/stream-endoscope";
        snapshot_url = "/snapshot-endoscope";
        aspect_ratio = "4:3";
        location = "nozzle";
        icon = "mdiPrinter3dNozzle";
        target_fps = 30;
        target_fps_idle = 15;
      };

      # Enable Telegram notification support.
      "notifier telegram" = {
        url = "tgram://{secrets.telegram.token}/{secrets.telegram.chat}";
        events = "*";
        body = "Your printer status has changed to {event_name}";
        attach = 
        [
          "http://127.0.0.1:${toString ports.ustreamer}/snapshot"
          "http://127.0.0.1:${toString ports.ustreamer-endoscope}/snapshot"
        ];
      };

      timelapse = {
        output_path = "${cfgPath}/timelapse/";
        ffmpeg_binary_path = "${pkgs.ffmpeg}/bin/ffmpeg";
        camera = "c920";
      };
    };
  };

  systemd.tmpfiles.settings."10-klipper" = {
    "${cfgPath}/config/timelapse.cfg"."L+" = {
      argument = pkgs.moonraker-timelapse.macroFile;
      user = config.services.moonraker.user;
      group = config.services.moonraker.group;
      mode = "0777";
    };

    "${cfgPath}/config/KAMP_Settings.cfg".C = {
      argument = "${kamp}/Configuration/KAMP_Settings.cfg";
      user = config.services.moonraker.user;
      group = config.services.moonraker.group;
      mode = "0777";
    };

    "${cfgPath}/config/Adaptive_Meshing.cfg"."L+" = {
      argument = "${kamp}/Configuration/Adaptive_Meshing.cfg";
      user = config.services.moonraker.user;
      group = config.services.moonraker.group;
      mode = "0777";
    };

    "${cfgPath}/config/Line_Purge.cfg"."L+" = {
      argument = "${kamp}/Configuration/Line_Purge.cfg";
      user = config.services.moonraker.user;
      group = config.services.moonraker.group;
      mode = "0777";
    };

    "${cfgPath}/config/Smart_Park.cfg"."L+" = {
      argument = "${kamp}/Configuration/Smart_Park.cfg";
      user = config.services.moonraker.user;
      group = config.services.moonraker.group;
      mode = "0777";
    };

    
  };

  networking.firewall.interfaces.gradientnet.allowedTCPPorts = [ ports.moonraker ];
  networking.firewall.interfaces.gradientnet.allowedUDPPorts = [ ports.moonraker ];

  networking.firewall.interfaces.lilynet.allowedTCPPorts = [ ports.moonraker ];
  networking.firewall.interfaces.lilynet.allowedUDPPorts = [ ports.moonraker ];

}