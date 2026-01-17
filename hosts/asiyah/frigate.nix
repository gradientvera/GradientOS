{ config, pkgs, ports, ... }:
let
  addresses = config.gradient.const.addresses;
  localAddresses = config.gradient.const.localAddresses;
  asiyahGradientnet = config.gradient.const.wireguard.addresses.gradientnet.asiyah;
in
{

  services.frigate = {
    enable = true;
    checkConfig = false;
    hostname = "frigate.asiyah.gradient.moe";
    vaapiDriver = "iHD";
    settings = {
      birdseye.enabled = false;
      birdseye.restream = false;
      birdseye.mode = "continuous";
      detect.enabled = true;
      motion.enabled = true;
      record.enabled = true;
      snapshots.enabled = true;
      snapshots.timestamp = true;

      mqtt.enabled = true;
      mqtt.host = "127.0.0.1";
      mqtt.port = ports.mqtt;
      tls.enabled = false;
      ffmpeg.path = pkgs.ffmpeg-full;
      ffmpeg.hwaccel_args = "preset-intel-qsv-h264";

      detectors = {
        ov_0 = {
          type = "openvino";
          device = "GPU";
        };
        ov_1 = {
          type = "openvino";
          device = "GPU";
        };
      };

      # Stateful step: https://docs.frigate.video/configuration/object_detectors/#yolov9
      model = {
        model_type = "yolo-generic";
        width = 320; # <--- should match whatever was set in notebook
        height = 320; # <--- should match whatever was set in notebook
        input_tensor = "nchw";
        input_dtype = "float";
        path = "/var/lib/frigate/yolov9-t-320.onnx";
        labelmap_path = "/var/lib/frigate/coco-80.txt";
      };

      audio = {
        enabled = true;
        listen = [
          "fire_alarm"
          "explosion"
          "shatter"
          "scream"
          "speech"
          "glass"
          "yell"
          "meow"
        ];
      };

      semantic_search = {
        enabled = false; # borked 
        model_size = "large";
      };

      face_recognition = {
        enabled = false; # borked
        model_size = "large";
      };

      genai = {
        enabled = false; # borked
        provider = "ollama";
        base_url = "http://127.0.0.1:${toString ports.ollama}";
        model = "llava:7b";
      };

      # Extremely important! Makes webrtc and two-way audio work
      go2rtc = config.services.go2rtc.settings;

      cameras = {
        eufy-e220-hallway = {
          enabled = true;
          webui_url = "http://${localAddresses.eufy-e220-hallway}";
          live.stream_name = "eufy-e220-hallway";
          live.streams = {
            "Main Stream" = "eufy-e220-hallway";
            "Sub Stream" = "eufy-e220-hallway_sub";
          };
          ffmpeg.output_args.record = "preset-record-generic-audio-aac";
          ffmpeg.inputs = [
            {
              path = "rtsp://127.0.0.1:${toString ports.go2rtc-rtsp}/eufy-e220-hallway?timeout=60";
              input_args = "preset-rtsp-restream";
              roles = [ "record" ];
            }
            {
              path = "rtsp://127.0.0.1:${toString ports.go2rtc-rtsp}/eufy-e220-hallway_sub?timeout=60";
              input_args = "preset-rtsp-restream";
              roles = [ "detect" "audio" ];
            }
          ];
          onvif = {
            host = localAddresses.eufy-e220-hallway-ip;
            port = 80;
            user = "thingino";
            password = "thingino";
            autotracking = {
              enabled = true;
              calibrate_on_startup = false;
              required_zones = [ "main" ];
              movement_weights = "0.0, 1.0, 0.08133125305175781, 0.10055391865391887, 0.21469116134028282, 0";
            };
          };
          zones = {
            main = {
              coordinates =	"0,0,1,0,1,1,0,1";
            };
          };
          genai = {
            enabled = false; # borked
            use_snapshots = true;
            objects = [ "person" ];
            required_zones = [ "main" ];
          };
        };
      };

    };
  };

  services.go2rtc = {
    enable = true;
    settings = {
      api.listen = ":${toString ports.frigate-go2rtc}";
      api.origin = "*";
      rtsp.listen = ":${toString ports.go2rtc-rtsp}";
      srtp.listen = ":${toString ports.go2rtc-srtp}";
      webrtc.listen = ":${toString ports.go2rtc-webrtc}";
      webrtc.candidates = [
        "${asiyahGradientnet}:${toString ports.go2rtc-webrtc}"
        "stun:${toString ports.go2rtc-webrtc}"
      ];
      webrtc.ice_servers = [
        { urls = [ "stun:stun.l.google.com:19302" ]; }
      ];
      streams = {
        # See https://github.com/AlexxIT/go2rtc/issues/857
        eufy-e220-hallway = [
          "rtsp://thingino:thingino@${localAddresses.eufy-e220-hallway-ip}/ch0#timeout=60"
          "ffmpeg:eufy-e220-hallway#audio=opus"
        ];
        eufy-e220-hallway_sub = [
          "rtsp://thingino:thingino@${localAddresses.eufy-e220-hallway-ip}/ch1#timeout=60"
          "ffmpeg:eufy-e220-hallway_sub#audio=opus"
        ];
      };
    };
  };

  services.nginx.virtualHosts."frigate.asiyah.gradient.moe" = {
    enableACME = false;
    useACMEHost = "gradient.moe";
    quic = true;
    addSSL = true;
    extraConfig = ''
      allow 127.0.0.1/8;
      allow ${config.gradient.const.wireguard.addresses.gradientnet.gradientnet}/24;
      deny all;
    '';
  };

  systemd.services.frigate = {
    after = [ "go2rtc.service" ];
    wants = [ "go2rtc.service" ];
  };

  systemd.services.go2rtc = {
    before = [ "frigate.service" ];
    wants = [ "frigate.service" ];
  };

  networking.firewall.interfaces.gradientnet = with ports; {
    allowedTCPPorts = [
      frigate
      frigate-api
      frigate-mqtt-ws
      frigate-jsmpeg
      frigate-go2rtc
      frigate-rtmp
      go2rtc-rtsp
      go2rtc-srtp
      go2rtc-webrtc
    ];
    allowedUDPPorts = [
      frigate
      frigate-api
      frigate-mqtt-ws
      frigate-jsmpeg
      frigate-go2rtc
      frigate-rtmp
      go2rtc-rtsp
      go2rtc-srtp
      go2rtc-webrtc
    ];
  };

}