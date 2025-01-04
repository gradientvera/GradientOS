{ config, pkgs, ... }:
{

  imports = [
    ./mqtt.nix
    ./backups.nix
    ./hostapd.nix
    ./programs.nix
    ./postgresql.nix
    ./filesystems.nix
    # ./ss14-watchdog.nix
    ./esphome/default.nix
    ./secrets/default.nix
    ./hardware-configuration.nix
  ];

  # Workaround, cross-compiling doesn't work so use the one from nixpkgs for now
  nix.package = pkgs.lix;

  gradient.presets.syncthing.enable = true;
  gradient.profiles.catppuccin.enable = true;

  gradient.substituters = {
    asiyah = "ssh-ng://nix-ssh@asiyah.gradient?priority=40";
    bernkastel = "ssh-ng://nix-ssh@bernkastel.gradient?priority=40";
    beatrice = "ssh-ng://nix-ssh@beatrice.gradient?priority=45";
    erika = "ssh-ng://nix-ssh@erika.gradient?priority=50";
    neith-deck = "ssh-ng://nix-ssh@neith-deck.lily?priority=100";
  };

}