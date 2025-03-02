{ ... }:

{

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.grub.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/5c03aea7-429f-4d50-80d0-b841db713659";
    fsType = "ext4";
    mountPoint = "/";
  };

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/C545-F839";
    fsType = "vfat";
    mountPoint = "/boot/efi";
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/460910b0-38ce-4710-80ec-1ffb7c774c1e"; }
  ];

}