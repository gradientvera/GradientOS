/*
*   Overlay for systems running a GradientOS-based configuration. 
*   Includes some package overrides and GradientOS-specific scripts.
*/
flake: final: prev:
let
  steam-override = {
    extraPkgs = pkgs: with pkgs; [
      # Extra Steam game dependencies go here.
      ffmpeg-full
      cups

      # Needed for Space Station 14 MIDI support.
      fluidsynth

      # Needed for GTK file dialogs in certain games.
      gtk3
      pango
      cairo
      atk
      zlib
      glib
      gdk-pixbuf

      # Useful tools for games
      gamescope # games cope hehehehehehehe
      gamemode
    ];
    extraArgs = "-console";
    extraEnv.ROBUST_SOUNDFONT_OVERRIDE = "${prev.soundfont-fluid}/share/soundfonts/FluidR3_GM2-2.sf2";
  };
in {
  discord = (prev.discord.override {
    withOpenASAR = true;
    withVencord = true;
    withTTS = true;
  }).overrideAttrs (prevAttrs: {
    desktopItem = prevAttrs.desktopItem.override (prevDesktopAttrs: {
      # Fixes xwaylandvideobridge.
      exec = "env NIXOS_OZONE_WL=0 XDG_SESSION_TYPE=x11 ${prevDesktopAttrs.exec}";
    });
  });

  moonlight-qt = prev.moonlight-qt.overrideAttrs (prevAttrs: {
    nativeBuildInputs = prevAttrs.nativeBuildInputs ++ [ prev.copyDesktopItems ];
    postInstall = prevAttrs.postInstall + ''
      rm $out/share/applications/com.moonlight_stream.Moonlight.desktop
    '';
    desktopItems = [
      (prev.makeDesktopItem {
        name = "Moonlight";
        # Needed for dead keys to work on Wayland.
        # Block access to /dev/video* to prevent crashes with special v4l2loopback config.
        exec = "env QT_QPA_PLATFORM=xcb SDL_DRIVER=x11 firejail --noprofile --blacklist=\"/dev/video*\" ${prevAttrs.meta.mainProgram}";
        icon = "moonlight";
        desktopName = "Moonlight";
        genericName = prevAttrs.meta.description;
        categories = [ "Qt" "Game" ];
      })
    ];
  });

  moonraker = prev.moonraker.overrideAttrs (final.moonraker-timelapse.moonrakerOverrideAttrs);

  steam = prev.steam.override steam-override;
  steam-original-fixed = final.unstable.steam.override steam-override;
  steam-deck-client = prev.callPackage ../pkgs/steam-deck-client.nix { };

  chromium = prev.chromium.override {
    enableWideVine = true;
  };

  appimage-run = prev.appimage-run.override {
    appimageTools = prev.appimageTools // {
      defaultFhsEnvArgs = prev.appimageTools.defaultFhsEnvArgs // { unshareIpc = false; unsharePid = false; };
    };
  };
  
  gradient-generator = flake.inputs.gradient-generator.packages.${prev.system}.default;

  gradientos-colmena = prev.callPackage ../pkgs/scripts/gradientos-colmena.nix { };
  gradientos-upgrade-switch = prev.callPackage ../pkgs/scripts/gradientos-upgrade-switch.nix { };
  gradientos-upgrade-boot = prev.callPackage ../pkgs/scripts/gradientos-upgrade-boot.nix { };
  gradientos-upgrade-test = prev.callPackage ../pkgs/scripts/gradientos-upgrade-test.nix { };

  nix-gaming = flake.inputs.nix-gaming.packages.${prev.system};

  # Unmodified unstable nixpkgs overlay.
  unstable = import flake.inputs.nixpkgs {
    inherit (prev) system;
    config.allowUnfree = true;
  };

  # Stable nixpkgs overlay.
  stable = import flake.inputs.nixpkgs-stable {
    inherit (prev) system;
    config.allowUnfree = true;
  };
}