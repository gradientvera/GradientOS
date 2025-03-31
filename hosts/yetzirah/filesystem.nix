{ ... }:
{

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/6c541d75-1ed6-4534-97ad-c0d0b341c3f7";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/BC07-8C50";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/8a13ff62-70d6-43eb-92f1-6db30dbc4bdf"; }
    ];

}