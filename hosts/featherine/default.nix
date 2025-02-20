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
  gradient.profiles.gaming.emulation.romPath = "/data/roms";
  gradient.profiles.desktop.enable = true;
  gradient.profiles.development.enable = true;
  gradient.profiles.catppuccin.enable = true;

  gradient.presets.syncthing.enable = true;

  # Android app support with waydroid.
  virtualisation.waydroid.enable = true;

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "vera";
  services.displayManager.defaultSession = lib.mkDefault "plasma";

  specialisation.deck-ui.configuration = { ... }:
  {
    # Use Jovian's steam deck UI autostart.
    services.displayManager.sddm.enable = lib.mkForce false;
    services.displayManager.autoLogin.enable = lib.mkForce false;
    jovian.steam.autoStart = lib.mkForce true;
  };

  jovian.steam.enable = true;
  jovian.steam.autoStart = false;
  jovian.steam.user = "vera";
  jovian.decky-loader.enable = true;
  jovian.decky-loader.user = "vera";
  jovian.steam.desktopSession = "plasma";

  jovian.devices.steamdeck.enable = lib.mkForce false;
  jovian.steamos.useSteamOSConfig = lib.mkForce false;

  services.openssh.openFirewall = true;

  services.handheld-daemon.enable = true;
  services.handheld-daemon.user = "vera";

  gradient.substituters = {
    asiyah = "ssh-ng://nix-ssh@asiyah.gradient?priority=40";
    briah = "ssh-ng://nix-ssh@briah.gradient?priority=60";
    beatrice = "ssh-ng://nix-ssh@beatrice.gradient?priority=45";
    bernkastel = "ssh-ng://nix-ssh@bernkastel.gradient?priority=40";
    neith-deck = "ssh-ng://nix-ssh@neith-deck.lily?priority=100";
  };

}