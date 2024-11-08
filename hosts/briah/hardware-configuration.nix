{ pkgs, lib, modulesPath, ... }:
{

  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "uas"
    "xhci_pci"
    "pcie-brcmstb"
    "reset-raspberrypi"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  boot.kernelPackages = pkgs.linuxPackages_rpi4;

  hardware.raspberry-pi."4".fkms-3d = {
    enable = true;
    cma = 256;
  };

  boot.loader.raspberryPi.firmwareConfig = ''
    arm_64bit=1
    arm_boost=1
    gpu_mem=256
    hdmi_force_hotplug=1
    enable_uart=1
    uart_2ndstage=1
    enable_gic=1
    armstub=RPI_EFI.fd
    disable_commandline_tags=1
    disable_overscan=1
    device_tree_address=0x1f0000
    device_tree_end=0x200000
    dtoverlay=miniuart-bt
    dtoverlay=upstream-pi4
    program_usb_boot_mode=1
  '';

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

}