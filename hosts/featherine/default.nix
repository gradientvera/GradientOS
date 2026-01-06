{ config, pkgs, lib, ... }:
{

  imports = [
    ./secrets
    ./backups.nix
    ./programs.nix
    ./ppd-hooks.nix
    ./filesystems.nix
    ./hardware-configuration.nix
  ];

  gradient.profiles.gaming.enable = true;
  gradient.profiles.gaming.emulation.romPath = "/data/roms";
  gradient.profiles.desktop.enable = true;
  gradient.profiles.desktop.wayland.autologin.enable = false;
  gradient.profiles.development.enable = true;
  gradient.profiles.catppuccin.enable = true;

  gradient.presets.syncthing.enable = true;

  # Android app support with waydroid.
  virtualisation.waydroid.enable = true;

  # Disable automatic login.
  services.displayManager.autoLogin.enable = lib.mkForce false;

  services.openssh.openFirewall = true;
  
  services.handheld-daemon = {
    user = "vera";
    enable = true;
    ui.enable = true;
    adjustor.enable = true;
    adjustor.loadAcpiCallModule = true;
  };

  # Use HHD instead
  services.inputplumber.enable = lib.mkForce false;
  

  # Dolphin Bluetooth passthrough
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="8087", ATTRS{idProduct}=="0032", TAG+="uaccess"
  '';

  gradient.substituters = {
    asiyah = "ssh-ng://nix-ssh@asiyah.gradient?priority=40";
    bernkastel = "ssh-ng://nix-ssh@bernkastel.gradient?priority=40";
  };

}