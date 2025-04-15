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
  boot.initrd.luks.devices."luks-723a41e3-725d-43ea-98f9-6e3be7908365" = {
    device = "/dev/disk/by-uuid/723a41e3-725d-43ea-98f9-6e3be7908365";
    crypttabExtraOpts = ["fido2-device=auto"];
    bypassWorkqueues = true;
  };

  boot.initrd.luks.devices."luks-1338fa28-7856-4a33-9e7a-0b0f08d7ee22" = {
    device = "/dev/disk/by-uuid/1338fa28-7856-4a33-9e7a-0b0f08d7ee22";
    crypttabExtraOpts = ["fido2-device=auto"];
    bypassWorkqueues = true;
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/45ba04fd-6c41-4a69-a613-cc4e0f6bf75a";
      fsType = "ext4";
      mountPoint = "/";
    };

    "/boot/efi" = {
      device = "/dev/disk/by-uuid/1073-6EE4";
      fsType = "vfat";
      mountPoint = "/boot/efi";
    };

    "/data" = {
      device = "/dev/disk/by-uuid/4bb789a6-064e-4d7e-80ea-5dd2093a04e2";
      fsType = "ext4";
      options = [ "rw" "noatime" "comment=x-gvfs-show" "nofail" ];
      mountPoint = "/data";
    };

    "/data2" = {
      device = "/dev/disk/by-uuid/47e81cce-06cd-46e9-9717-224616fb4147";
      fsType = "ext4";
      options = [ "rw" "noatime" "comment=x-gvfs-show" "nofail" ];
      mountPoint = "/data2";
    };

    "/home/vera/tmp" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [ "rw" "nodev" "nosuid" "comment=x-gvfs-show" ];
      mountPoint = "/home/vera/tmp";
    };
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/02626a2a-ecb6-455d-a258-e03a1bb896d4"; }
  ];

}