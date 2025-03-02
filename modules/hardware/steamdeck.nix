{ config, lib, pkgs, self, ... }:
let
  cfg = config.gradient;
in
{

  options = {
    gradient.hardware.steamdeck.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to enable Steam Deck support, using Jovian-NixOS.
      '';
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.hardware.steamdeck.enable {
      
    })
  ];

}