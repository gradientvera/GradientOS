{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.kernelPackages = pkgs.linuxPackages_xanmod;
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "uas" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ ];

  boot.kernelParams = [

  ];

  # Piece of shit fucking wifi adapter *fuck you*
  hardware.usb-modeswitch.enable = true;

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.eno1.useDHCP = lib.mkDefault true;

  networking.networkmanager.wifi.powersave = false;

  networking.networkmanager.ensureProfiles = {
    profiles = {

      Maya = {
        connection = {
          id = "Maya";
          permissions = "";
          type = "wifi";
          autoconnect = "true";
        };
        ipv4 = {
          method = "auto";
        };
        ipv6 = {
          addr-gen-mode = "default";
          method = "auto";
        };
        wifi = {
          mac-address-blacklist = "";
          mode = "infrastructure";
          ssid = "Maya";
        };
        wifi-security = {
          key-mgmt = "wpa-psk";
          auth-alg = "open";
          psk = "$MAYA_WIFI_PASSWORD";
        };
      };

    };

    environmentFiles = [
      config.sops.secrets.network-manager-env.path
    ];
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
