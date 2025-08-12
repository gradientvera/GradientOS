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
  gradient.profiles.development.enable = true;
  gradient.profiles.catppuccin.enable = true;

  gradient.profiles.gaming.vr = {
    enable = true;
    patchAmdgpu = true;
    wivrn.enable = true;
    wivrn.default = true;
    monado.enable = true;
    monado.default = false;
  };

  gradient.profiles.audio.um2.enable = true;

  gradient.presets.syncthing.enable = true;

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "vera";
  services.displayManager.defaultSession = "plasma";

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

  hardware.amdgpu.overdrive.enable = true;

  # WOL support.
  networking.interfaces.enp16s0.wakeOnLan.enable = true;

  gradient.substituters = {
    asiyah = "ssh-ng://nix-ssh@asiyah.gradient?priority=40";
    beatrice = "ssh-ng://nix-ssh@beatrice.gradient?priority=45";
    erika = "ssh-ng://nix-ssh@erika.gradient?priority=50";
    neith-deck = "ssh-ng://nix-ssh@neith-deck.lily?priority=100";
  };

  # Share QL-600 printer!
  services.printing = {
    openFirewall = false;
    defaultShared = true;
    browsing = true;
  };

}
