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
    ];
  };
in {
  discord = (prev.discord.override {
    withOpenASAR = true;
    withVencord = true;
    withTTS = true;
  }).overrideAttrs (prevAttrs: {
    desktopItem = prevAttrs.desktopItem.override (prevDesktopAttrs: {
      # Force wayland, enable middle click, use pipewire for screenshare
      exec = "env NIXOS_OZONE_WL=1 ELECTRON_OZONE_PLATFORM_HINT=wayland ${prevDesktopAttrs.exec} --enable-blink-features=MiddleClickAutoscroll --enable-features=WebRTCPipeWireCapturer";
    });
  });

  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (
      python-final: python-prev: {
        # See https://github.com/NixOS/nixpkgs/pull/413385
        # Needed for pinchflat and yt-dlp to be able to impersonate again
        curl-cffi = (python-prev.buildPythonPackage rec {
        pname = "curl-cffi";
        version = "0.12.1b2";
        src = prev.fetchurl {
          url = "https://github.com/lexiforest/curl_cffi/releases/download/v${version}/curl_cffi-${version}-cp39-abi3-manylinux_2_17_x86_64.manylinux2014_x86_64.whl";
          hash = "sha256-J4TZkJbluJ1fg4cXrMmBsjnEL8INoRof37txBgx0T4E=";
        };
        format = "wheel";
        buildInputs = [ prev.stdenv.cc.cc.lib ];
        nativeBuildInputs = [
          prev.stdenv.cc.cc.lib
          prev.autoPatchelfHook
        ];
      });
      }
    )
  ];

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
  
  gradient-generator = flake.inputs.gradient-generator.packages.${prev.system}.default;

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

  # Master branch nixpkgs overlay.
  master = import flake.inputs.nixpkgs-master {
    inherit (prev) system;
    config.allowUnfree = true;
  };
}