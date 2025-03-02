{ osConfig, ... }:
{

  nix.registry = osConfig.nix.registry;

  home.sessionVariables.NIX_PATH = (builtins.concatStringsSep ":" osConfig.nix.nixPath);

  nix.gc = {
    automatic = true;
    persistent = true;
    frequency = "daily";
    options = "--delete-older-than 7d";
  };

}