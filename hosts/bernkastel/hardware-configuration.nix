{ config, pkgs, modulesPath, ... }:

{

  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" "amdgpu" "xhci_hcd" "tpm_crb" ];
  boot.initrd.kernelModules = [ "amdgpu" "tpm_crb" ];
  boot.kernelModules = [ "amdgpu-i2c" "kvm-amd" "i2c-dev" "i2c-piix4" "it87" "tpm_crb" ];
  boot.kernelParams = [
    # iommu stuff
    "amd_iommu=on"
    "iommu=pt"
    "iommu=1"
    "video=efifb:off"

    # needed for controlling RGB LEDs on RAM sticks
    "acpi_enforce_resources=lax"
  ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ amdgpu-i2c ];
  boot.extraModprobeConfig = ''
    options it87 ignore_resource_conflict=1 force_id=0x8622
  '';

  nixpkgs.hostPlatform = "x86_64-linux";
}

