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

      environment.systemPackages = [
        pkgs.force-xwayland
      ];
    })
  ];

}