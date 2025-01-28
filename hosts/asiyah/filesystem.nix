{ config, lib, ... }:
{

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.grub.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  services.zfs = {
    trim.enable = true;
    autoScrub.enable = true;
  };

  fileSystems."/" = {
    device = "/dev/disk/by-partuuid/c9299d68-3b61-43d7-b234-e92ad1c47e78";
    fsType = "ext4";
    mountPoint = "/";
  };

  fileSystems."/data" = {
    device = "data";
    fsType = "zfs";
    options = [ "zfsutil" ];
  };

  fileSystems."/boot" = { 
    device = "/dev/disk/by-partuuid/77de2f8b-6eea-49cc-b0d4-d13291232a45";
    fsType = "vfat";
    mountPoint = "/boot";
  };

  swapDevices = [
    { device = "/dev/disk/by-partuuid/94a96e54-d944-4240-a59b-71c642a9e07e"; priority = 100; }
  ];

}