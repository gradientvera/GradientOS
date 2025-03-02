{ config, lib, pkgs, modulesPath, ... }:
{

  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "thunderbolt" "usbhid" "usb_storage" "sd_mod" "amdgpu" "xhci_hcd" ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelModules = [ "kvm-amd" "i2c-dev" ];
  boot.kernelParams = [
    "pci=nommconf"
    "rtc_cmos.use_acpi_alarm=1"
  ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ ];
  boot.extraModprobeConfig = "";

  # Breaks suspend due to ppfeaturemask
  programs.corectrl = {
    enable = lib.mkForce false;
    gpuOverclock.enable = lib.mkForce false;
  };

  hardware.sensor.iio.enable = true;

  nixpkgs.hostPlatform = "x86_64-linux";

}