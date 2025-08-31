{ osConfig, ... }:
{

  nix.registry = osConfig.nix.registry;

  home.sessionVariables.NIX_PATH = (builtins.concatStringsSep ":" osConfig.nix.nixPath);

  nix.gc = {
    automatic = true;
    persistent = true;
    dates = "15:00";
    options = "--delete-older-than 7d";
  };

}