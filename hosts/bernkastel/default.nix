 { config, pkgs, ... }:
 let
  ports = config.gradient.currentHost.ports;
in
 {

  imports = [
    ./backups.nix
    ./programs.nix
    ./filesystems.nix
    ./secrets/default.nix
    # ./libvirtd/default.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "bernkastel";

  gradient.profiles.gaming.enable = true;
  gradient.profiles.gaming.emulation.romPath = "/data/roms";
  gradient.profiles.desktop.enable = true;
  gradient.profiles.desktop.wayland.autologin.enable = false;
  gradient.profiles.development.enable = true;
  gradient.profiles.catppuccin.enable = true;

  gradient.profiles.gaming.vr = {
    enable = true;
    patchAmdgpu = true;
    envision.enable = true;
    wivrn.enable = true;
    wivrn.default = true;
    monado.enable = true;
    monado.default = false;
  };

  gradient.profiles.audio.um2.enable = true;

  gradient.presets.syncthing.enable = true;

  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
    package = pkgs.openrgb-with-all-plugins;
    server.port = ports.openrgb;
  };

  networking.firewall.interfaces.gradientnet.allowedTCPPorts = [ ports.openrgb ];
  networking.firewall.interfaces.gradientnet.allowedUDPPorts = [ ports.openrgb ];

  # Overclocking/underclocking AMD GPU support
  programs.corectrl = {
    enable = true;
  };

  # Buggy? Not the pirate clown! As in, this is prolly quite bug-prone
  # hardware.amdgpu.overdrive.enable = true;

  # WOL support.
  networking.interfaces.enp14s0.wakeOnLan.enable = true;

  # Dolphin Bluetooth passthrough
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0489", ATTRS{idProduct}=="e10d", TAG+="uaccess"
  '';

  systemd.tmpfiles.settings."10-amdgpu-x3d.conf" = {
    "/sys/bus/platform/drivers/amd_x3d_vcache/AMDI0101:00/amd_x3d_mode".w = {
      argument = "cache";
    };
  };

  gradient.substituters = {
    asiyah = "ssh-ng://nix-ssh@asiyah.gradient?priority=40";
    erika = "ssh-ng://nix-ssh@erika.gradient?priority=50";
  };

  # Share QL-600 printer!
  services.printing = {
    openFirewall = false;
    defaultShared = true;
    browsing = true;
  };

}
