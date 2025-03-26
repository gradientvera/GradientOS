{ ... }:

{

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.grub.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  # Enable swap on luks
  boot.initrd.luks.devices."luks-3053e826-9bee-46c6-b7ca-86d8a34fc307".device = "/dev/disk/by-uuid/3053e826-9bee-46c6-b7ca-86d8a34fc307";
  boot.initrd.luks.devices."luks-3053e826-9bee-46c6-b7ca-86d8a34fc307".bypassWorkqueues = true;
  boot.initrd.luks.devices."luks-4ddc036e-9ff2-44a8-ad72-080243230631".device = "/dev/disk/by-uuid/4ddc036e-9ff2-44a8-ad72-080243230631";
  boot.initrd.luks.devices."luks-4ddc036e-9ff2-44a8-ad72-080243230631".bypassWorkqueues = true;
  boot.initrd.luks.devices."luks-4ddc036e-9ff2-44a8-ad72-080243230631".keyFile = "/crypto_keyfile.bin";

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/ed52dbed-453d-4eb5-bc09-0cce0113f8a5";
      fsType = "ext4";
      mountPoint = "/";
    };

  
  fileSystems."/boot/efi" =
    { device = "/dev/disk/by-uuid/8F40-DE56";
      fsType = "vfat";
      mountPoint = "/boot/efi";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/7e7e4425-bdcf-437c-b7f0-a6849429bb36"; }
    ];

}