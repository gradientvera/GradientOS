{ config, lib, ... }:
{

  imports = [
    ./secrets
    ./backups.nix
    ./programs.nix
    ./filesystems.nix
    ./hardware-configuration.nix
  ];

  gradient.profiles.gaming.enable = true;
  gradient.profiles.desktop.enable = true;
  gradient.profiles.development.enable = true;
  gradient.profiles.catppuccin.enable = true;

  gradient.presets.syncthing.enable = true;

  # Android app support with waydroid.
  virtualisation.waydroid.enable = true;

  # Use Jovian's steam deck UI autostart.
  services.displayManager.sddm.enable = lib.mkForce false;
  jovian.steam.autoStart = true;
  jovian.steam.user = "vera";
  jovian.decky-loader.user = "vera";
  jovian.steam.desktopSession = "plasma";

  services.handheld-daemon.enable = true;

  gradient.substituters = {
    asiyah = "ssh-ng://nix-ssh@asiyah.gradient?priority=40";
    briah = "ssh-ng://nix-ssh@briah.gradient?priority=60";
    beatrice = "ssh-ng://nix-ssh@beatrice.gradient?priority=45";
    bernkastel = "ssh-ng://nix-ssh@bernkastel.gradient?priority=40";
    neith-deck = "ssh-ng://nix-ssh@neith-deck.lily?priority=100";
  };

}