{ config, pkgs, modulesPath, ... }:

{

  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" "amdgpu" "xhci_hcd" ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelModules = [ "amdgpu-i2c" "kvm-amd" "i2c-dev" "i2c-piix4" "it87" ];
  boot.kernelParams = [
    # iommu stuff
    "amd_iommu=on"
    "iommu=pt"
    "iommu=1"
    "video=efifb:off"

    # needed for controlling RGB LEDs on RAM sticks
    "acpi_enforce_resources=lax"

    # enable amdgpu overclocking, see https://wiki.archlinux.org/title/AMDGPU#Boot_parameter
    # "amdgpu.ppfeaturemask=0xfff7ffff"
  ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ amdgpu-i2c ];
  boot.extraModprobeConfig = ''
    options it87 ignore_resource_conflict=1 force_id=0x8622
  '';

  nixpkgs.hostPlatform = "x86_64-linux";

}

