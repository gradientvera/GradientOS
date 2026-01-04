{ pkgs, config, lib, ... }:
let
  auroraUuid = "20d3ee15-2596-4c2c-92b8-af5bd7c0b096";
in
{

  # Bootloader.
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
    autoGenerateKeys.enable = true;
    autoEnrollKeys = {
      enable = true;
      # Automatically reboot to enroll the keys in the firmware
      autoReboot = true;
    };
  };

  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-4b159de8-a815-46ef-94bd-52a9d0e03e3a" = {
    device = "/dev/disk/by-uuid/4b159de8-a815-46ef-94bd-52a9d0e03e3a";
    bypassWorkqueues = true;
    crypttabExtraOpts = [ "tpm2-device=auto" ];
  };
  boot.initrd.luks.devices."luks-5300f6ce-cc89-429c-8656-50e5bf71f13d" = {
    device = "/dev/disk/by-uuid/5300f6ce-cc89-429c-8656-50e5bf71f13d";
    bypassWorkqueues = true;
    crypttabExtraOpts = [ "tpm2-device=auto" ];
  };

  # SD Card
  boot.initrd.luks.devices."luks-${auroraUuid}" = {
    device = "/dev/disk/by-uuid/${auroraUuid}";
    bypassWorkqueues = false; # not an SSD
    crypttabExtraOpts = [ "tpm2-device=auto" ];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/5931ef19-0224-4c5d-820b-269facdfa31b";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/B871-5205";
    fsType = "vfat";
  };

  fileSystems."/data" = {
    device = "/dev/disk/by-uuid/e44adef8-7bcf-42eb-ae52-25e69e6a27d8";
    fsType = "ext4";
    options = [ "defaults" "rw" "nofail" "noatime" "x-systemd.automount" "x-systemd.device-timeout=1ms" "comment=x-gvfs-show" ];
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/08db435c-35ee-41ab-9373-e69a575e9955"; }
  ];

  environment.systemPackages = [
    (pkgs.writeShellScriptBin "decrypt-aurora" ''
      sudo ${pkgs.cryptsetup}/bin/cryptsetup luksOpen /dev/disk/by-uuid/${auroraUuid} luks-${auroraUuid} --key-file=${config.sops.secrets.aurora-key-file.path}
      sudo ${pkgs.util-linux}/bin/mount /data
    '')
    (pkgs.writeShellScriptBin "encrypt-aurora" ''
      sudo ${pkgs.util-linux}/bin/umount /data
      sudo ${pkgs.cryptsetup}/bin/cryptsetup luksClose luks-${auroraUuid}
    '')
  ];

  systemd.services.aurora-sleep-fix = {
    wantedBy = [ "sleep.target" ];
    before = [ "sleep.target" ];
    serviceConfig.User = "root";
    serviceConfig.Type = "oneshot";
    serviceConfig.RemainAfterExit = "yes";
    unitConfig.StopWhenUnneeded = "yes";
    path = [ pkgs.cryptsetup ];
    script = ''
      cryptsetup luksSuspend /dev/mapper/luks-${auroraUuid}
    '';
    postStop = ''
      cryptsetup luksResume /dev/mapper/luks-${auroraUuid} --key-file=${config.sops.secrets.aurora-key-file.path}
    '';
  };

}