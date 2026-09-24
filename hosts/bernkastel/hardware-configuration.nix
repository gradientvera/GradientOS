{
  config,
  pkgs,
  modulesPath,
  ...
}:

{

  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  hardware.facter.reportPath = ./facter.json;

  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
    "usbhid"
    "usb_storage"
    "sd_mod"
    "amdgpu"
    "xhci_hcd"
    "tpm_crb"
    "tpm_tis"
    "tpm"
  ];
  boot.initrd.kernelModules = [
    "amdgpu"
    "tpm_crb"
    "tpm_tis"
    "tpm"
  ];
  boot.kernelModules = [
    "amdgpu-i2c"
    "kvm-amd"
    "i2c-dev"
    "i2c-piix4"
    "it87"
    "tpm_crb"
    "tpm_tis"
    "tpm"
  ];
  boot.kernelParams = [
    "amd_iommu=on"
    "iommu=pt"

    # See https://wiki.archlinux.org/title/Power_management/Wakeup_triggers#ACPI_OSI_string
    "acpi_osi=\"!Windows 2015\""

    # needed for controlling RGB LEDs on RAM sticks, also fixes some ACPI errors
    "acpi_enforce_resources=no"

    # Fix bluetooth? See https://discuss.cachyos.org/t/bluetooth-connection-disconnection-cycling/20027/32
    "usbcore.autosuspend=-1"
    "btusb.enable_autosuspend=n"
  ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ amdgpu-i2c ];
  boot.extraModprobeConfig = ''
    options it87 ignore_resource_conflict=1 force_id=0x8622
  '';

  systemd.services.fix-suspend-wakeup = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig.User = "root";
    serviceConfig.Type = "oneshot";
    serviceConfig.RemainAfterExit = "yes";
    script = "echo GPP0 > /proc/acpi/wakeup";
  };

  # Network card (AQC113) is sometimes missing on boot
  # Shitty workaround but hey it works!
  systemd.services.nic-watchdog = {
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    serviceConfig.User = "root";
    serviceConfig.Type = "oneshot";
    path = with pkgs; [ pciutils coreutils systemd ];
    script =
      let
        state = "/var/lib/nic-watchdog.count";
      in
      ''
        if lspci -d 1d6a:: 2>/dev/null | grep -q .; then
          rm -f ${state}
          exit 0
        fi
        n=$(cat ${state} 2>/dev/null || echo 0)
        if [ "$n" -ge 2 ]; then
          echo "NIC still missing after 2 auto-reboots! Not rebooting again..."
          exit 1
        fi
        echo $((n + 1)) > ${state}
        echo "NIC missing at boot (attempt $((n + 1))/2), rebooting in 10 seconds (cancel: systemctl stop nic-watchdog)"
        sleep 10
        systemctl reboot
      '';
  };

  nixpkgs.hostPlatform = "x86_64-linux";
}
