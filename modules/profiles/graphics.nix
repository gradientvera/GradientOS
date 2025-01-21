{ config, lib, pkgs, ... }:
let
  cfg = config.gradient;
in
{

  options = {
    gradient.profiles.graphics.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to enable the GradientOS graphics profile.
      '';
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.profiles.graphics.enable {
      hardware.graphics.enable = true;
      hardware.graphics.enable32Bit = true;

      # Enable touchpad support
      services.libinput.enable = true;

      # Taken from Bazzite at https://github.com/ublue-os/bazzite/blob/17c869dc70eede3f7066a8ad9ed07f46798fa9b3/system_files/deck/shared/usr/lib/udev/rules.d/80-gpu-reset.rules
      services.udev.extraRules = ''
        ACTION=="change", ENV{DEVNAME}=="/dev/dri/card0", ENV{RESET}=="1", ENV{PID}!="0", RUN+="${pkgs.coreutils}/bin/kill -9 %E{PID}"
      '';

      environment.systemPackages = [
        pkgs.force-xwayland
      ];
    })
  ];

}