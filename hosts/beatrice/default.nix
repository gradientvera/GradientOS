{ config, lib, pkgs, ... }:

{

  imports = [
    ./backups.nix
    ./klipper.nix
    ./programs.nix
    ./mainsail.nix
    ./ustreamer.nix
    ./moonraker.nix
    ./filesystems.nix
    ./kiosk-session.nix
    ./secrets/default.nix
    ./specialisations
    ./hardware-configuration.nix
  ];

  networking.hostName = "beatrice";

  gradient.profiles.graphics.enable = true;
  gradient.profiles.catppuccin.enable = true;

  gradient.presets.syncthing.enable = true;

  services.handheld-daemon.enable = true;
  services.handheld-daemon.user = "vera";

  gradient.substituters = {
    asiyah = "ssh-ng://nix-ssh@asiyah.gradient?priority=40";
    briah = "ssh-ng://nix-ssh@briah.gradient?priority=60";
    bernkastel = "ssh-ng://nix-ssh@bernkastel.gradient?priority=40";
    erika = "ssh-ng://nix-ssh@erika.gradient?priority=50";
    neith-deck = "ssh-ng://nix-ssh@neith-deck.lily?priority=100";
  };

}