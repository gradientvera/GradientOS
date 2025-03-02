/*
*   Overlay for systems running a GradientOS-based configuration. 
*   Includes some package overrides and GradientOS-specific scripts.
*/
flake: final: prev:
let
  steam-override = {
    extraArgs = "-console";
    extraEnv.ROBUST_SOUNDFONT_OVERRIDE = "${prev.soundfont-fluid}/share/soundfonts/FluidR3_GM2-2.sf2";
    extraPkgs = pkgs: with pkgs; [
      ffmpeg-full
      cups # Needed by Cookie Clicker because electron lol
      
      # Useful tools for games
      gamescope # games cope hehehehehehehe
      gamemode
    ];
    extraLibraries = pkgs: with pkgs; [
      # Extra Steam game dependencies go here.
      nss

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
    ];
  };
in {
  discord = (final.master.discord.override {
    withOpenASAR = true;
    withVencord = true;
    withTTS = true;
  }).overrideAttrs (prevAttrs: {
    desktopItem = prevAttrs.desktopItem.override (prevDesktopAttrs: {
      # Force wayland, enable middle click
      exec = "env NIXOS_OZONE_WL=1 ELECTRON_OZONE_PLATFORM_HINT=wayland ${prevDesktopAttrs.exec} --enable-blink-features=MiddleClickAutoscroll";
    });
  });

  emulationstation-de = (prev.emulationstation-de.override { libgit2 = final.stable.libgit2; icu = final.icu75; });

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

  # master branch nixpkgs overlay.
  # ...because why the hell not, I want to use discord screensharing with audio now aaa
  master = import flake.inputs.nixpkgs-master {
    inherit (prev) system;
    config.allowUnfree = true;
  };
}