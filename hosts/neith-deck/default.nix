{ config, lib, ... }:

{

  imports = [
    ./programs.nix
    ./filesystems.nix
    ./secrets/default.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "neith-deck";

  gradient.profiles.gaming.enable = true;
  gradient.profiles.desktop.enable = true;
  gradient.profiles.catppuccin.enable = false;

  gradient.presets.syncthing.enable = true;
  gradient.presets.syncthing.user = "neith";

  # Use Jovian's steam deck UI autostart.
  services.displayManager.sddm.enable = lib.mkForce false;
  jovian.steam.autoStart = true;
  jovian.steam.user = "neith";
  jovian.decky-loader.user = "neith";
  jovian.steam.desktopSession = "plasma";

  services.handheld-daemon.enable = true;
  services.handheld-daemon.user = "vera";

  gradient.substituters = {
    asiyah = "ssh-ng://nix-ssh@asiyah.lily?priority=50";
    briah = "ssh-ng://nix-ssh@briah.lily?priority=60";
    bernkastel = "ssh-ng://nix-ssh@bernkastel.lily?priority=50";
    beatrice = "ssh-ng://nix-ssh@beatrice.gradient?priority=45";
    erika = "ssh-ng://nix-ssh@erika.lily?priority=50";
  };

}