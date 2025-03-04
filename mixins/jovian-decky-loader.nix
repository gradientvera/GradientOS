{ config, pkgs, lib, ... }:
{

  # Requires enabling CEF remote debugging on the Developer menu settings to work.
  jovian.decky-loader.enable = true;
  jovian.decky-loader.extraPackages = with pkgs; [
    power-profiles-daemon
    inotify-tools
    libpulseaudio
    coreutils
    gamescope
    gamemode
    mangohud
    pciutils
    systemd
    gnugrep
    python3
    gnused
    procps
    steam
    gawk
    file
  ];
  jovian.decky-loader.extraPythonPackages = pythonPkgs: with pythonPkgs; [
    click
  ];

  systemd.services.decky-loader.environment.LD_LIBRARY_PATH = lib.makeLibraryPath config.jovian.decky-loader.extraPackages;

}