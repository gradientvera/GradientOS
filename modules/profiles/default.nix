{ config, lib, pkgs, ... }:
let
  cfg = config.gradient;
in
{

  imports = [
    ./audio/default.nix
    ./gaming/default.nix

    ./desktop.nix
    ./graphics.nix
    ./catppuccin.nix
    ./development.nix
  ];

  options = {
    gradient.profiles.default.enable = lib.mkOption {
      type = lib.types.bool;
      default = cfg.core.enable;
      description = ''
        Whether to enable the default GradientOS profile.
        Includes some pre-installed utilities and programs.
      '';
    };
  };

  config = lib.mkIf cfg.profiles.default.enable {
    programs.git.enable = true;
    programs.git.lfs.enable = true;

    services.udev.packages = with pkgs; [
      steam-devices-udev-rules
      game-devices-udev-rules
      android-udev-rules
      qmk-udev-rules
    ];

    environment.systemPackages = with pkgs; [
      (with dotnetCorePackages; combinePackages [
        dotnet_8.sdk
        dotnet_8.aspnetcore
        dotnet_9.sdk
        dotnet_9.aspnetcore
      ])
      gradientos-upgrade-switch
      gradientos-upgrade-boot
      gradientos-upgrade-test
      gradientos-colmena
      smartmontools
      appimage-run
      imagemagick
      ffmpeg-full
      nix-weather
      lm_sensors
      ssh-to-age
      distrobox
      nfs-utils
      powertop
      usbutils
      pciutils
      nettools
      pmutils
      colmena
      tcpdump
      sysstat
      python3
      screen
      yt-dlp
      p7zip
      just
      sops
      gmic
      lsof
      htop
      btop
      file
      cloc
      nil
      age
      dig
      eza
    ] ++ (if pkgs.system == "x86_64-linux" then [
      unrar
      rar
    ] else if pkgs.system == "aarch64-linux" then [

    ] else []);
  };

}