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
    device = "/dev/disk/by-uuid/599884aa-ad46-44e0-8616-3ef644cf6fab";
    fsType = "ext4";
    mountPoint = "/";
  };

  fileSystems."/data" = {
    device = "data";
    fsType = "zfs";
    options = [ "zfsutil" ];
  };

  fileSystems."/boot" = { 
    device = "/dev/disk/by-uuid/2B43-E0C0";
    fsType = "vfat";
    mountPoint = "/boot";
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/57eb5b85-fd37-4345-ba94-5ac155c89a46"; priority = 100; }
  ];

}