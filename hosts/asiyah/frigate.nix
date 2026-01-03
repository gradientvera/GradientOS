{ config, pkgs, ports, ... }:
{

  services.frigate = {
    enable = true;
    hostname = "frigate.asiyah.gradient.moe";
    vaapiDriver = "iHD";
    settings = {
      mqtt.enabled = true;
      mqtt.host = "127.0.0.1:${toString ports.mqtt}";
      tls.enabled = false;
      ffmpeg.path = pkgs.ffmpeg-full;
      cameras = {};
    };
  };

  services.nginx.virtualHosts."frigate.asiyah.gradient.moe".extraConfig = ''
    allow ${config.gradient.const.wireguard.addresses.gradientnet.gradientnet}/24;
    deny all;
  '';

}