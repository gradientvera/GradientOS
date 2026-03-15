{ config, ... }:
let
  hostName = config.networking.hostName;
in
{

  specialisation.rescue = {
    inheritParentConfig = false;
    configuration = {
      imports = [
        ./openssh.nix
        ./network.nix
        ../hosts/${hostName}/hardware-configuration.nix
        ../hosts/${hostName}/filesystem.nix
      ];
    };
  };

}