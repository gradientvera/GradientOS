/*
*   Overlay for systems running a GradientOS-based configuration. 
*   Includes some package overrides and GradientOS-specific scripts.
*/
flake: final: prev:
let
  steam-override = {
    extraArgs = "-console -pipewire";
    extraPkgs = pkgs: with pkgs; [
      ffmpeg-full
      cups # Needed by Cookie Clicker because electron lol
      
      # Useful tools for games
      gamescope # games cope hehehehehehehe
      gamemode

      # See: https://wiki.nixos.org/wiki/Steam#Gamescope_fails_to_launch_when_used_within_Steam
      libxcursor
      libxi
      libxinerama
      libxscrnsaver
      libpng
      libpulseaudio
      libvorbis
      stdenv.cc.cc.lib # Provides libstdc++.so.6
      libkrb5
    ];
    extraLibraries = pkgs: with pkgs; [
      # Extra Steam game dependencies go here.
      nss

      # Needed for GTK file dialogs in certain games.
      gtk3
      pango
      cairo
      atk
      zlib
      glib
      gdk-pixbuf
      libpng
      libpulseaudio
      libvorbis
      stdenv.cc.cc.lib # Provides libstdc++.so.6
      libkrb5
    ];
  };
  discord-override = pkg: (pkg.override {
    withOpenASAR = true;
    withVencord = true;
    withTTS = true;
  }).overrideAttrs (prevAttrs: {
    desktopItem = prevAttrs.desktopItem.override (prevDesktopAttrs: {
      # Force wayland, enable middle click, use pipewire for screenshare
      exec = "env NIXOS_OZONE_WL=1 ELECTRON_OZONE_PLATFORM_HINT=wayland ${prevDesktopAttrs.exec} " 
        + "--enable-blink-features=MiddleClickAutoscroll --enable-features=UseOzonePlatform,WebRTCPipeWireCapturer "
        + "--enable-gpu-rasterization --ignore-gpu-blocklist --enable-zero-copy ";
    });
  });
in {
  crowdsec = prev.crowdsec.overrideAttrs (prevAttrs: {
    nativeBuildInputs = prevAttrs.nativeBuildInputs ++ [ prev.patchelf ];
    subPackages = prevAttrs.subPackages ++ [ "cmd/notification-http" ];
    postFixup = ''
      interp="$(cat $NIX_CC/nix-support/dynamic-linker)"
      patchelf --set-interpreter $interp $out/bin/notification-http
    '';
  });

  discord = discord-override prev.discord;
  discord-canary = discord-override prev.discord-canary;

  # gotenberg = prev.gotenberg.override { pdfcpu = final.stable.pdfcpu; };

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

  paperless-ngx = prev.paperless-ngx.overrideAttrs (prevAttrs: {
    # Causes build failures every so often and frankly I don't care
    doCheck = false;
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
  
  gradient-generator = flake.inputs.gradient-generator.packages.${prev.stdenv.hostPlatform.system}.default;

  nix-gaming = flake.inputs.nix-gaming.packages.${prev.stdenv.hostPlatform.system};

  # Unmodified unstable nixpkgs overlay.
  unstable = import flake.inputs.nixpkgs {
    inherit (prev) config;
    localSystem.system = prev.stdenv.hostPlatform.system;
  };

  # Stable nixpkgs overlay.
  stable = import flake.inputs.nixpkgs-stable {
    # For some reason we need to define replaceStdenv here?
    # TODO: Check after the next stable version upgrade
    config = prev.config // { replaceStdenv = { pkgs }: pkgs.stdenv; };
    localSystem.system = prev.stdenv.hostPlatform.system;
    overlays = [
      (import ./gradientos.nix flake)
      (import ./gradientpkgs.nix)
      (import ./home-assistant.nix)
    ];
  };

  # Master branch nixpkgs overlay.
  master = import flake.inputs.nixpkgs-master {
    inherit (prev) config;
    localSystem.system = prev.stdenv.hostPlatform.system;
    overlays = [
      (import ./gradientos.nix flake)
      (import ./gradientpkgs.nix)
      (import ./home-assistant.nix)
    ];
  };
}