{ config, pkgs, lib, ... }:
let
  cfg = config.gradient;
in
{

  # TODO: Turn these into proper modules
  imports = [
    ./openssh.nix
    ./network.nix
    ./workarounds.nix
    ./nix-channels.nix
  ];

  options = {
    gradient.core.nixos.enable = lib.mkOption {
      type = lib.types.bool;
      default = cfg.core.enable;
      description = ''
        Whether to enable NixOS-specific core GradientOS configurations.
        Enables some extra services by default, and also enables systemd-based initrd.
      '';
    };
  };

  config = lib.mkIf cfg.core.nixos.enable {
    services.fstrim.enable = true;
    services.fwupd.enable = true;

    services.devmon.enable = true;
    services.gvfs.enable = true;
    services.udisks2.enable = true;

    services.avahi.enable = true;
    services.avahi.nssmdns4 = true;
    services.avahi.publish = {
      enable = true;
      domain = true;
      addresses = true;
    };

    # Performance and power saving
    services.auto-cpufreq.enable = true;
    services.power-profiles-daemon.enable = lib.mkForce false;
    services.irqbalance.enable = true;

    # Convenience
    services.envfs.enable = true;
    
    services.ananicy = {
      enable = true;
      package = pkgs.ananicy-cpp;
      rulesProvider = pkgs.ananicy-rules-cachyos;
      extraRules = import ./ananicy-rules.nix;
    };

    security.rtkit.enable = true;
    security.polkit.enable = true;

    programs.dconf.enable = true;
    programs.nix-ld.enable = true;

    # Mainly for the security wrapper + firejail in PATH
    programs.firejail.enable = true;

    hardware.enableRedistributableFirmware = true;

    systemd.extraConfig = ''
      DefaultTimeoutStopSec=30s
    '';

    environment.shells = with pkgs; [
      nushell
    ]; 

    # systemd-based initrd
    boot.initrd.systemd.enable = true;

    boot.kernel.sysctl = {
      "kernel.sysrq" = 1;
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";
    };

    # Automatically restart 30 seconds after a kernel panic
    boot.kernelParams = [ "panic=30" ];

    boot.supportedFilesystems = {
      "ntfs" = true;
      "nfs" = true;
      "nfs4" = true;
    };

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "22.11"; # Did you read the comment?
  };

}