{ config, lib, pkgs, self, ... }:
let
  hostName = config.networking.hostName;
in
{

  specialisation.rescue = {
    inheritParentConfig = false;
    configuration = {
      imports = [
        # For the hosts that need it, otherwise unused
        self.inputs.lanzaboote.nixosModules.lanzaboote
        
        # Allow remote SSH
        ./openssh.nix
        ./network.nix

        # Could be needed
        ./secrets/default.nix
        ../hosts/${hostName}/secrets/default.nix
        
        # Definitely needed
        ../users/vera/default.nix
        ../hosts/${hostName}/hardware-configuration.nix
        ../hosts/${hostName}/filesystems.nix
      ];

      # Keep hostname at least!
      networking.hostName = hostName;

      # Needed for ZFS
      networking.hostId = config.networking.hostId;

      # Make everything as basic as possible
      users.users.vera.shell = lib.mkForce pkgs.bash;

      nix.package = pkgs.lix;
      gradient.core.secrets.enable = true;

      # "Essential" recovery tools
      environment.systemPackages = with pkgs; [
        nixos-install-tools
        git
        curl
        htop
        sbctl

      ];

      # Well? Did YOU read the comment? Fuckwad
      system.stateVersion = config.system.stateVersion;
    };
  };

}