{ config, pkgs, lib, modulesPath, ... }:
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
    powerManagement.powertop.enable = true;
    services.power-profiles-daemon.enable = true; # Replace with "tuned" when available
    services.thermald.enable = lib.mkIf (pkgs.system != "aarch64-linux") true;
    services.irqbalance.enable = true;

    # Convenience
    # services.envfs.enable = true;
    
    services.ananicy = {
      enable = true;
      package = pkgs.ananicy-cpp;
      rulesProvider = pkgs.ananicy-rules-cachyos;
      extraRules = import ./ananicy-rules.nix;
    };

    security.rtkit = {
      enable = true;
      # As per https://gitlab.freedesktop.org/pipewire/pipewire/-/wikis/Performance-tuning#rtkit
      args = [
        "--scheduling-policy=FIFO"
        "--our-realtime-priority=89"
        "--max-realtime-priority=88"
        "--min-nice-level=-19"
        "--rttime-usec-max=2000000"
        "--users-max=100"
        "--processes-per-user-max=1000"
        "--threads-per-user-max=10000"
        "--actions-burst-sec=10"
        "--actions-per-burst-max=1000"
        "--canary-cheep-msec=30000"
        "--canary-watchdog-msec=60000"
      ];  
    };
    security.polkit.enable = true;
    security.auditd.enable = true;
    services.journald.audit = true;
    security.audit.enable = true;
    security.audit.rules = [
      "-a exit,always -F arch=b64 -S execve"
    ];

    programs.dconf.enable = true;
    programs.nix-ld.enable = true;

    # Convenience
    programs.appimage.binfmt = true;
    programs.java.binfmt = true;

    # Mainly for the security wrapper + firejail in PATH
    programs.firejail.enable = true;

    hardware.enableRedistributableFirmware = true;

    # Increase number of files per process
    # prevents build failures sometimes
    systemd.extraConfig = ''
      DefaultTimeoutStopSec=30s
      DefaultLimitNOFILE=16384:524288
    '';

    systemd.user.extraConfig = ''
      DefaultTimeoutStopSec=30s
      DefaultLimitNOFILE=16384:524288
    '';

    environment.shells = with pkgs; [
      nushell
    ]; 

    # Enable systemd watchdog.
    systemd.watchdog = {
      runtimeTime = "10s";
      rebootTime = "45s";
      kexecTime = "45s";
    };

    security.pam.u2f = {
      enable = true;
      settings.cue = true;
    };

    # systemd-based initrd
    boot.initrd.systemd.enable = true;

    boot.kernel.sysctl = {
      "kernel.sysrq" = "1";
      
      # Enable the BBR congestion control algorithm
      "net.core.default_qdisc" = "cake";
      "net.ipv4.tcp_congestion_control" = "bbr";
      
      # Enable TCP Fast Open
      "net.ipv4.tcp_fastopen" = "3";
      
      # Enable MTU probing
      "net.ipv4.tcp_mtu_probing" = lib.mkDefault true;

      # Log martian packets
      "net.ipv4.conf.default.log_martians" = "1";
      "net.ipv4.conf.all.log_martians" = "1";

      # DOS prevention
      "net.ipv4.tcp_max_syn_backlog" = "8192";
      "net.ipv4.tcp_max_tw_buckets" = "2000000";
      "net.ipv4.tcp_tw_reuse" = "1";
      "net.ipv4.tcp_fin_timeout" = "10";
      "net.ipv4.tcp_slow_start_after_idle" = "0";
      "net.ipv4.tcp_syncookies" = "1";

      # Increase inotify watches
      "fs.inotify.max_user_instances" = "524288";
      "fs.inotify.max_user_watches" =  "524288"; 
    };

    # For handhelds etc
    boot.initrd.unl0kr.settings.general.backend = "drm";
    
    # Automatically restart 30 seconds after a kernel panic
    boot.kernelParams = [ "panic=30" ];

    boot.supportedFilesystems = {
      "ntfs" = true;
      "nfs" = true;
      "nfs4" = true;
    };

    boot.loader.systemd-boot.netbootxyz.enable = true;

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "22.11"; # Did you read the comment?
  };

}