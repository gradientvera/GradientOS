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
    services.thermald.enable = lib.mkIf (pkgs.stdenv.hostPlatform.system != "aarch64-linux") true;
    services.irqbalance.enable = true;

    # See https://github.com/NixOS/nixpkgs/issues/299476 and https://github.com/NixOS/nixpkgs/issues/408800
    services.dbus.implementation = "broker";

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
    security.auditd.settings = {
      # For Crowdsec
      log_group = config.users.groups.auditd.name;
    };
    users.groups.auditd = {};
    services.journald.audit = true;
    security.audit.enable = true;
    security.audit.rules = [
      # Very spammy, not very useful
      # "-a exit,always -F arch=b64 -S execve"
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
    systemd.settings.Manager = {
      DefaultTimeoutStopSec = "30s";
      DefaultLimitNOFILE = "32768:1048576";

      # Enable systemd watchdog.
      RuntimeWatchdogSec = "10s";
      RebootWatchdogSec = "45s";
      KExecWatchdogSec = "45s";
    };

    systemd.user.extraConfig = ''
      DefaultTimeoutStopSec=30s
      DefaultLimitNOFILE=32768:1048576
    '';

    security.pam.loginLimits = [
      {
        domain = "*";
        type = "soft";
        item = "nofile";
        value = "32768";
      }
      {
        domain = "*";
        type = "hard";
        item = "nofile";
        value = "1048576";
      }
    ];

    environment.shells = with pkgs; [
      fish
    ];

    programs.fish = {
      enable = true;
      shellInit = ''
        function fish_greeting
          echo $(whoami)@$(hostname) - $(date --iso-8601) - $(date +%T)
        end
      '';
    };
    programs.starship = {
      enable = true;
      settings = {
        hostname.disabled = false;
        username.disabled = false;
        dotnet.disabled = false;
        direnv.disabled = false;
      };
      presets = [
        "nerd-font-symbols"
      ];
    };
    programs.nix-index.enable = true;
    programs.nix-index.enableFishIntegration = true;

    security.pam.u2f = {
      enable = true;
      settings.cue = true;
    };

    # sudo but in rust?? hoooly hell
    security.sudo.enable = false;
    security.sudo-rs.enable = true;

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

      # Increase max amount of connections
      "net.core.somaxconn" = "8192";

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

    # Slow to build, fails to build on containers too
    documentation.man.generateCaches = lib.mkForce false;

    boot.loader.systemd-boot.netbootxyz.enable = true;

    # Put jemalloc on a consistent folder, for use with LD_PRELOAD
    systemd.tmpfiles.settings."10-jemalloc"."/run/jemalloc"."L+".argument = toString pkgs.jemalloc;

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "22.11"; # Did you read the comment?
  };

}