{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.kernelPackages = pkgs.linuxPackages_xanmod;
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "uas" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" "8852au" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [
    (rtl8852au.overrideAttrs (prevAttrs: {
      patches = [
        # Linux 6.13 support
        (pkgs.fetchpatch {
          name = "remove-MODULE_IMPORT-and-net_device-for-kernel-versions-over-6.13.patch";
          url = "https://github.com/natimerry/rtl8852au/commit/c65ed43f42656aecf43e7ea80c58d204c3c67aca.patch";
          hash = "sha256-l6ZBeI2PGQq11UBMiV/l8Ofry9FZH1KSBDwROXxnYHU=";
        })
        # Linux 6.14 support
        (pkgs.fetchpatch {
          name = "get_tx_power-callback-by-adding-link_id-parameter.patch";
          url = "https://github.com/natimerry/rtl8852au/commit/91d168fc5aa818b4e85aa5b2b43d7f25470e925c.patch";
          hash = "sha256-2dET83eVIU1PXdJJO1HWg3a81/6ztVwh0uN6VzXbG3o=";
        }) 
      ];
    }))
  ];

  boot.kernelParams = [
    # Switch to USB3.0 mode
    "8852au.rtw_switch_usb_mode=1"
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
