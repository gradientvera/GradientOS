{ config, pkgs, ... }:
let
  ports = config.gradient.currentHost.ports;
in {
  systemd.services.ustreamer = {
    description = "ustreamer webcam streamer";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      User = "ustreamer";
      Group = "video";
      Restart = "always";
      RestartSec = 1;
      Nice="-10";
    };
    script = ''exec ${pkgs.ustreamer}/bin/ustreamer \
      --device /dev/v4l/by-id/usb-046d_HD_Pro_Webcam_C920-video-index0 \
      --host 0.0.0.0 \
      --port ${builtins.toString ports.ustreamer} \
      --format MJPEG \
      --resolution 1280x720 \
      --desired-fps 30 \
      --drop-same-frames 30 \
      --last-as-blank 60 \
      --device-timeout 60 \
      --workers 4 \
      --buffers 5 \
      --image-default \
      --slowdown \
      --quality 100 \
      --persistent \
      --encoder cpu'';
  };

  systemd.services.ustreamer-endoscope = {
    description = "ustreamer endoscope streamer";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      User = "ustreamer";
      Group = "video";
      Restart = "always";
      RestartSec = 1;
      Nice="-10";
    };
    script = ''exec ${pkgs.ustreamer}/bin/ustreamer \
      --device /dev/v4l/by-id/usb-Generic_USB2.0_PC_CAMERA-video-index0 \
      --host 0.0.0.0 \
      --port ${builtins.toString ports.ustreamer-endoscope} \
      --format YUYV \
      --resolution 640x480 \
      --desired-fps 30 \
      --drop-same-frames 30 \
      --last-as-blank 60 \
      --device-timeout 60 \
      --workers 4 \
      --buffers 5 \
      --image-default \
      --slowdown \
      --quality 100 \
      --persistent \
      --encoder cpu'';
  };

  services.mainsail.nginx.locations = {
    "/stream".extraConfig = ''
      postpone_output 0;
      proxy_buffering off;
      proxy_ignore_headers X-Accel-Buffering;
      proxy_pass http://127.0.0.1:${toString ports.ustreamer}/stream;
    '';
    "/snapshot".extraConfig = ''
      proxy_pass http://127.0.0.1:${toString ports.ustreamer}/snapshot;
    '';
    "/stream-endoscope".extraConfig = ''
      postpone_output 0;
      proxy_buffering off;
      proxy_ignore_headers X-Accel-Buffering;
      proxy_pass http://127.0.0.1:${toString ports.ustreamer-endoscope}/stream;
    '';
    "/snapshot-endoscope".extraConfig = ''
      proxy_pass http://127.0.0.1:${toString ports.ustreamer-endoscope}/snapshot;
    '';
  };

  users.users.ustreamer = {
    description = "User for webcam streaming";
    isSystemUser = true;
    group = "video";
  };

  networking.firewall.interfaces.gradientnet.allowedTCPPorts = [ ports.ustreamer ports.ustreamer-endoscope ];
  networking.firewall.interfaces.gradientnet.allowedUDPPorts = [ ports.ustreamer ports.ustreamer-endoscope ];

  networking.firewall.interfaces.lilynet.allowedTCPPorts = [ ports.ustreamer ports.ustreamer-endoscope ];
  networking.firewall.interfaces.lilynet.allowedUDPPorts = [ ports.ustreamer ports.ustreamer-endoscope ];

}