{ config, lib, pkgs, ... }:
let
  cfg = config.gradient;
in
{

  options = {
    gradient.profiles.desktop.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to enable the GradientOS desktop profile.
        Enables audio, graphics and some extras such as flatpak support.
      '';
    };

    gradient.profiles.desktop.wayland.enable = lib.mkOption {
      type = lib.types.bool;
      default = cfg.profiles.desktop.enable;
      description = ''
        Whether to enable the GradientOS custom wayland config.
        Enabled by default when the desktop profile is enabled.
      '';
    };

    gradient.profiles.desktop.wayland.autologin.enable = lib.mkOption {
      type = lib.types.bool;
      default = cfg.profiles.desktop.wayland.enable;
      description = ''
        Whether to enable the GradientOS autologin wayland workaround.
        Enabled by default when the desktop wayland profile is enabled.
      '';
    };

    gradient.profiles.desktop.wayland.environment.enable = lib.mkOption {
      type = lib.types.bool;
      default = cfg.profiles.desktop.wayland.enable;
      description = ''
        Whether to enable some environment variables which make most programs use their native wayland backend.
        Enabled by default when the desktop wayland profile is enabled.
      '';
    };

    gradient.profiles.desktop.fonts.enable = lib.mkOption {
      type = lib.types.bool;
      default = cfg.profiles.desktop.enable;
      description = ''
        Whether to enable the GradientOS custom font config.
        Enabled by default when the desktop profile is enabled.
      '';
    };

    gradient.profiles.desktop.kde.enable = lib.mkOption {
      type = lib.types.bool;
      default = cfg.profiles.desktop.enable;
      description = ''
        Whether to enable KDE Plasma as the desktop environment.
        Enabled by default when the desktop profile is enabled.
      '';
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.profiles.desktop.enable {
      gradient.profiles.audio.enable = true;
      gradient.profiles.graphics.enable = true;

      # Enable portals.
      xdg.portal.enable = true;
      xdg.portal.xdgOpenUsePortal = true;
      xdg.autostart.enable = true;
      
      # Enable flatpak
      services.flatpak.enable = true;
      services.packagekit.enable = true;

      programs.partition-manager.enable = true;

      environment.systemPackages = with pkgs; [
        kdePackages.filelight
        moonlight-qt
      ];

    })

    (lib.mkIf (cfg.profiles.desktop.enable && cfg.profiles.desktop.wayland.enable) {
      # Enable XWayland for X11 compat when using wayland.
      programs.xwayland.enable = true;

      environment.systemPackages = with pkgs; [
        wlr-randr
        waypipe
      ];
    })

    (lib.mkIf (cfg.profiles.desktop.enable && cfg.profiles.desktop.wayland.enable && cfg.profiles.desktop.wayland.autologin.enable) {
      # Hack to get Wayland autologin to work.
      systemd.services."getty@tty1".enable = false;
      systemd.services."autovt@tty1".enable = false;
    })

    (lib.mkIf (cfg.profiles.desktop.enable && cfg.profiles.desktop.wayland.enable && cfg.profiles.desktop.wayland.environment.enable) {
      # Wayland support for most applications.
      environment.sessionVariables = {
        NIXOS_OZONE_WL = "1";
        
        # Apparently not a good idea to set the below env vars
        # SDL_VIDEODRIVER = "wayland";
        # GDK_BACKEND = "wayland";
        # QT_QPA_PLATFORM = "wayland";
        # XDG_SESSION_TYPE = "wayland";
      };
    })

    (lib.mkIf (cfg.profiles.desktop.enable && cfg.profiles.desktop.fonts.enable) {
      fonts = {
        fontDir.enable = true;
        fontconfig = {
          enable = true;
          antialias = true;
          cache32Bit = true;
          subpixel.rgba = "rgb";
          hinting = {
            enable = true;
            autohint = false;
          };
          defaultFonts = {
            monospace = [ "NotoSansM Nerd Font Mono" ];
            sansSerif = [ "NotoSans Nerd Font" ];
            serif = [ "Noto Serif" ];
            emoji = [ "Twitter Color Emoji" "Noto Color Emoji" "Noto Emoji" ];
          };
        };
        enableDefaultPackages = true;
        packages = with pkgs; [
          noto-fonts-monochrome-emoji
          nerd-fonts.sauce-code-pro
          noto-fonts-emoji-blob-bin
          nerd-fonts.ubuntu-sans
          noto-fonts-color-emoji
          nerd-fonts.roboto-mono
          noto-fonts-cjk-sans
          twitter-color-emoji
          ttf_bitstream_vera
          fira-code-symbols
          source-serif-pro
          nerd-fonts.noto
          source-code-pro
          source-sans-pro
          ubuntu-classic
          google-fonts
          dejavu_fonts
          roboto-serif
          roboto-slab
          roboto-mono
          roboto-flex
          noto-fonts
          fira-mono
          fira-code
          corefonts
          unifont
          roboto
          fira
        ];
      };
    })

    (lib.mkIf (cfg.profiles.desktop.enable && cfg.profiles.desktop.kde.enable) {
      # Enable the KDE Plasma Desktop Environment.
      services.displayManager.sddm.enable = true;
      services.displayManager.sddm.wayland.enable = true;
      services.displayManager.sddm.wayland.compositor = "kwin";
      services.desktopManager.plasma6.enable = true;

      programs.kdeconnect.enable = true;

      services.power-profiles-daemon.enable = true;
      
      environment.systemPackages = with pkgs; [
        kdePackages.powerdevil
        kdePackages.kio-admin
        kdePackages.discover
        kdePackages.sddm-kcm
        pinentry-qt
      ];
    })
  ];

}