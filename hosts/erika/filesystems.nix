{ ... }:
{

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-c3cd1e3f-45ef-4009-bdf4-73dfab099aaa".device = "/dev/disk/by-uuid/c3cd1e3f-45ef-4009-bdf4-73dfab099aaa";
  boot.initrd.luks.devices."luks-93e2669c-48fc-47e6-8a36-ed31eeda94b3".device = "/dev/disk/by-uuid/93e2669c-48fc-47e6-8a36-ed31eeda94b3";

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/8cf3b135-2696-4e08-9b0d-85205cde8321";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/C773-7A18";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/46e82990-2470-4b76-afbb-99e21b12867e"; }
    ];
  
}