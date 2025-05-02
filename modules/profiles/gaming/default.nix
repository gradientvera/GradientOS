{ config, lib, pkgs, ... }:
let
  cfg = config.gradient;
in 
{

  imports = [
    ./emulation.nix
    ./virtual-reality.nix
  ];

  options = {
    gradient.profiles.gaming.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to enable the GradientOS gaming profile.
        Includes some common videogames and nice performance tweaks.
      '';
    };

    gradient.profiles.gaming.openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = cfg.profiles.gaming.enable;
      description = ''
        Whether to open ports 7777 to 7787 and ports 25565 to 25566.
        Useful for hosting videogame servers and the like without having to modify the system config.
      '';
    };

    gradient.profiles.gaming.installGames = lib.mkOption {
      type = lib.types.bool;
      default = cfg.profiles.gaming.enable;
      description = ''
        Whether to install some games and game utilities that I, personally, like!
      '';
    };

    gradient.profiles.gaming.kernelTweaksEnabled = lib.mkOption {
      type = lib.types.bool;
      default = cfg.profiles.gaming.enable;
      description = ''
        Whether to tweak some kernel configuration for gaming, based on CryoUtilities.
      '';
    };

  };

  config = lib.mkMerge [
    (lib.mkIf cfg.profiles.gaming.enable {
      gradient.profiles.desktop.enable = true;
    })

    (lib.mkIf (cfg.profiles.gaming.openFirewall) {
      # For games and such.
      networking.firewall.allowedTCPPortRanges = [ { from=7777; to=7787; } ];
      networking.firewall.allowedUDPPortRanges = [ { from=7777; to=7787; } ];
    })

    (lib.mkIf (cfg.profiles.gaming.installGames) {
      # Conflicting definition for capSysNice behavior
      programs.gamescope = if (config ? "jovian" && config.jovian.steam.enable) then {
        enable = true;
      }
      else {
        enable = true;
        capSysNice = true;
      };

      programs.gamemode.enable = true;

      # Remote gaming hell yeah! Must be started manually for "security"
      services.sunshine = {
        enable = true;
        capSysAdmin = true;
        openFirewall = true;
        autoStart = lib.mkDefault false;
      };

      services.joycond.enable = true;
      
      environment.systemPackages = with pkgs; [
        space-station-14-launcher
        osu-lazer-bin
        prismlauncher
        vintagestory
        xivlauncher
        steam-run
        heroic
        lutris
      ];
    })

    (lib.mkIf (cfg.profiles.gaming.kernelTweaksEnabled) {
      # Performance tweaks based on CryoUtilities
      gradient.kernel = {
        hugepages = {
          enable = true;
          defrag = "0";
          sharedMemory = "advise";
        };
        swappiness = 1;
        pageLockUnfairness = 1;
        compactionProactiveness = 0;
      };
    })
  ];

}