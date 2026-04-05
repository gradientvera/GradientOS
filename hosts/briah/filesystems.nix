{ config, ... }:
{

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
  };

  fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };
  fileSystems."/boot" = { device = "/dev/disk/by-uuid/34CD-7DCE"; fsType = "vfat"; };

}