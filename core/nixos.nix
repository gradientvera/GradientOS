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
    
    # Do NOT reenable until https://gitlab.com/ananicy-cpp/ananicy-cpp/-/issues/40
    # or systemd will eat your fucking face due to the cgroups v1 deprecation
    #services.ananicy = {
    #  enable = true;
    #  package = pkgs.ananicy-cpp;
    #  rulesProvider = pkgs.ananicy-rules-cachyos;
    #  extraRules = import ./ananicy-rules.nix;
    #};

    security.rtkit.enable = true;
    security.polkit.enable = true;

    programs.dconf.enable = true;
    programs.nix-ld.enable = true;

    # Mainly for the security wrapper + firejail in PATH
    programs.firejail.enable = true;

    hardware.enableRedistributableFirmware = true;

    environment.shells = with pkgs; [
      nushell
    ]; 

    # systemd-based initrd
    boot.initrd.systemd.enable = true;

    boot.kernel.sysctl = {
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";
    };

    boot.supportedFilesystems = [ "ntfs" ];

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "22.11"; # Did you read the comment?
  };

}