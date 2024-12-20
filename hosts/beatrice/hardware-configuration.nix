{ modulesPath, pkgs, lib, ... }:

{

  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_xanmod_latest;
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" "sr_mod" "sdhci_pci" "amdgpu" "xhci_hcd" "hid_generic" "atkbd" "hid-multitouch" "evdev" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  boot.plymouth.enable = lib.mkForce false;
  boot.initrd.unl0kr.enable = true;
  hardware.amdgpu.initrd.enable = false;

  nixpkgs.hostPlatform = "x86_64-linux";
  
}