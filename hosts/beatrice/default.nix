{ config, lib, pkgs, ... }:

{

  imports = [
    ./backups.nix
    ./programs.nix
    ./filesystems.nix
    ./secrets/default.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "beatrice";

  gradient.profiles.graphics.enable = true;
  gradient.profiles.catppuccin.enable = true;

  gradient.presets.syncthing.enable = true;

  services.handheld-daemon.enable = true;
  services.handheld-daemon.user = "vera";

  gradient.profiles.gaming.enable = true;
  gradient.profiles.gaming.emulation.enable = false;
  gradient.profiles.gaming.emulation.romPath = "/run/media/deck/mmcblk0p1/roms";
  gradient.profiles.desktop.enable = true;

  # Use Jovian's steam deck UI autostart.
  services.displayManager.sddm.enable = lib.mkForce false;
  jovian.steam.autoStart = true;
  jovian.steam.user = "vera";
  jovian.decky-loader.user = "vera";
  jovian.steam.desktopSession = "plasma";

  gradient.substituters = {
    asiyah = "ssh-ng://nix-ssh@asiyah.gradient?priority=40";
    briah = "ssh-ng://nix-ssh@briah.gradient?priority=60";
    bernkastel = "ssh-ng://nix-ssh@bernkastel.gradient?priority=40";
    erika = "ssh-ng://nix-ssh@erika.gradient?priority=50";
    neith-deck = "ssh-ng://nix-ssh@neith-deck.lily?priority=100";
  };

}