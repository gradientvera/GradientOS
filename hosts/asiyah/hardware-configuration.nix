{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  # Stable for ZFS
  boot.kernelPackages = pkgs.linuxPackages_xanmod;
  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" "xhci_hcd" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" "nfs" "corsair-psu" "iTCO_wdt" ];
  boot.extraModulePackages = [ ];

  boot.kernelParams = [
    "pcie_aspm=off"
    "intel_iommu=on"
  ];

  # We've got enough RAM to do this LET'S GOOO
  boot.tmp.useTmpfs = true;
  boot.tmp.tmpfsSize = "75%"; 

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.eno1.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}