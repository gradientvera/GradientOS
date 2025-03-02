{ config, pkgs, ... }:
{

  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];

  environment.systemPackages = [
    pkgs.v4l-utils
  ];

  boot.kernelModules = [ "v4l2loopback" ];

  # Allow using the virtual camera device with the browser. Also gives it a pretty name!
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=21 exclusive_caps=1 card_label="Virtual Webcam"
  '';

}