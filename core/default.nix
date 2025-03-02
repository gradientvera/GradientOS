{ config, lib, self, ... }:
let
  cfg = config.gradient;
in  
{

  imports = [
    ./nix.nix
    ./nixos.nix
    ./constants.nix
    ./installer.nix
    ./secrets/default.nix
  ];

  options = {
    gradient.core.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether to enable the core GradientOS configuration.
      '';
    };
  };

  config = lib.mkIf cfg.core.enable {
    system.configurationRevision = lib.mkIf (self ? rev) self.rev;
    system.autoUpgrade.flake = "github:gradientvera/GradientOS";
  };

}