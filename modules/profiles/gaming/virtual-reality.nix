{ config, lib, pkgs, self, ... }:
let
  cfg = config.gradient;
  adb = "${pkgs.android-tools}/bin/adb";
  pkgs-xr = self.inputs.nixpkgs-xr.packages.${pkgs.stdenv.hostPlatform.system};

  # As per https://github.com/olekolek1000/wayvr-dashboard#assigning-wayvr-dashboard-to-the-wayvr-config-in-wlx-overlay-s
  wayvr-dashboard-yaml = pkgs.writeText "wayvr-dashboard.yaml" ''
    dashboard:
      exec: "${pkgs-xr.wayvr-dashboard}/bin/wayvr-dashboard"
      args: ""
      env: []
  '';
  wayvr-dashboard-location = "~/.config/wlxoverlay/wayvr.conf.d/dashboard.yaml";
  install-wayvr-dashboard = pkgs.writeShellScriptBin "install-wayvr-dashboard" ''
    mkdir -p ~/.config/wlxoverlay/wayvr.conf.d/
    rm -f ${wayvr-dashboard-location}
    ln -s ${toString wayvr-dashboard-yaml} ${wayvr-dashboard-location}
  '';
in 
{

  options = {

    gradient.profiles.gaming.vr.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to enable the GradientOS virtual reality gaming profile.
        Includes some utilities and VR support.
      '';
    };

    gradient.profiles.gaming.vr.installUtilities = lib.mkOption {
      type = lib.types.bool;
      default = cfg.profiles.gaming.vr.enable;
      description = ''
        Whether to install some VR utilities.
      '';
    };

    gradient.profiles.gaming.vr.patchAmdgpu = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to patch amdgpu to ignore process privileges and allow any application to create high priority contexts.
        Needed for asynchronous reprojection to work with SteamVR.
      '';
    };

    gradient.profiles.gaming.vr.monado.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to set up Monado. Needs some manual setup for hand tracking.
      '';
    };

    gradient.profiles.gaming.vr.monado.default = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to set up Monado as the default OpenXR runtime systemwide.
      '';
    };

    gradient.profiles.gaming.vr.wivrn.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to set up WiVRn.
      '';
    };
    
    gradient.profiles.gaming.vr.wivrn.androidId = lib.mkOption {
      type = lib.types.str;
      default = "org.meumeu.wivrn";
      description = ''
        Android app identifier to use when using the wivrn-usb script to connect a standalone VR headset to your computer.
        See: https://github.com/WiVRn/WiVRn?tab=readme-ov-file#how-do-i-use-a-wired-connection
      '';
    };

    gradient.profiles.gaming.vr.wivrn.default = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to set up WiVRn as the default OpenXR runtime systemwide.
      '';
    };

    gradient.profiles.gaming.vr.steam.pressure-vessel-filesystems-rw = lib.mkOption {
      type = (lib.types.listOf lib.types.str);
      default = [];
      description = ''
        Paths to add to Steam's PRESSURE_VESSEL_FILESYSTEMS_RW environment variable.
      '';
    };

  };

  config = lib.mkMerge [

    (lib.mkIf cfg.profiles.gaming.vr.enable {

      programs.steam.package = pkgs.steam.override {
        extraEnv = {
          PRESSURE_VESSEL_FILESYSTEMS_RW = (lib.concatStringsSep ":" cfg.profiles.gaming.vr.steam.pressure-vessel-filesystems-rw);
        };
      };

      environment.systemPackages = [
        (let
          mkOpenVr = name: runtimePath: pkgs.writeText name ''
            {
              "config" :
              [
                "~/.local/share/Steam/config"
              ],
              "external_drivers" : null,
              "jsonid" : "vrpathreg",
              "log" :
              [
                "~/.local/share/Steam/logs"
              ],
              "runtime" :
              [
                "${runtimePath}"
              ],
              "version" : 1
            }
          '';
          steamOpenVr = mkOpenVr "steamvr.vrpath" "~/.local/share/Steam/steamapps/common/SteamVR";
          openCompositeVr = mkOpenVr "opencomposite.vrpath" "${pkgs.opencomposite}/lib/opencomposite";
          openCompositeUnstableVr = mkOpenVr "opencompositeUnstable.vrpath" "${pkgs-xr.opencomposite}/lib/opencomposite";
          xrizerVr = mkOpenVr "xrizer.vrpath" "${pkgs.xrizer}/lib/xrizer";
          xrizerUnstableVr = mkOpenVr "xrizerUnstable.vrpath" "${pkgs-xr.xrizer}/lib/xrizer";
        in pkgs.writeScriptBin "openvr-runtime" ''
          #!/usr/bin/env -S ${pkgs.just}/bin/just --chooser=${pkgs.fzf}/bin/fzf --justfile

          vrpath := "~/.config/openvr/openvrpaths.vrpath"

          alias steamvr := steam
          alias openc := opencomposite

          @_default:
            openvr-runtime --choose

          @_link SOURCE:
            ln -s {{SOURCE}} {{vrpath}}

          @_copy SOURCE:
            cp {{SOURCE}} {{vrpath}}
            chmod 777 {{vrpath}}

          @_clean:
            mkdir -p $(${pkgs.coreutils}/bin/dirname {{vrpath}})
            rm -f {{vrpath}}

          clean: _clean
            @echo "Cleaned user OpenVR runtime, will default to systemwide runtime."

          steam: _clean (_copy "${toString steamOpenVr}")
            @echo "Set SteamVR as the OpenVR runtime."

          opencomposite: _clean (_link "${toString openCompositeVr}")
            @echo "Set OpenComposite as the OpenVR runtime."

          opencompositeUnstable: _clean (_link "${toString openCompositeUnstableVr}")
            @echo "Set OpenComposite (unstable) as the OpenVR runtime."

          xrizer: _clean (_link "${toString xrizerVr}")
            @echo "Set XRizer as the OpenVR runtime."

          xrizerUnstable: _clean (_link "${toString xrizerUnstableVr}")
            @echo "Set XRizer (unstable) as the OpenVR runtime."

        '')
        (let
          monadoXr = "${pkgs.monado}/share/openxr/1/openxr_monado.json";
          monadoUnstableXr = "${pkgs-xr.monado}/share/openxr/1/openxr_monado.json";
          wivrnXr = "${config.services.wivrn.package}/share/openxr/1/openxr_wivrn.json";
          steamXr = "~/.local/share/Steam/steamapps/common/SteamVR/steamxr_linux64.json";
        in pkgs.writeScriptBin "openxr-runtime" ''
          #!/usr/bin/env -S ${pkgs.just}/bin/just --chooser=${pkgs.fzf}/bin/fzf --justfile

          xrpath := "~/.config/openxr/1/active_runtime.json"
          alias steamxr := steam
          alias steamvr := steam

          @_default:
            openxr-runtime --choose

          @_link SOURCE:
            ln -s {{SOURCE}} {{xrpath}}

          @_clean:
            mkdir -p $(${pkgs.coreutils}/bin/dirname {{xrpath}})
            rm -f {{xrpath}}

          clean: _clean
            @echo "Cleaned user OpenXR runtime, will default to systemwide runtime."

          steam: _clean (_link "${steamXr}")
            @echo "Set SteamVR as the OpenXR runtime."

          monado: _clean (_link "${monadoXr}")
            @echo "Set Monado as the OpenXR runtime."

          monadoUnstable: _clean (_link "${monadoUnstableXr}")
            @echo "Set Monado (unstable) as the OpenXR runtime."

          wivrn: _clean (_link "${wivrnXr}")
            @echo "Set WiVRn as the OpenXR runtime."

        '')
      ];

    })

    (lib.mkIf (cfg.profiles.gaming.vr.enable && cfg.profiles.gaming.vr.installUtilities) {

      programs.steam.extraCompatPackages = [
        # Better for VRChat etc
        pkgs-xr.proton-ge-rtsp-bin
      ];

      programs.alvr = {
        enable = true;
        package = pkgs.master.alvr;
        openFirewall = true;
      };

      environment.systemPackages = with pkgs; [
        (writeShellScriptBin "amdgpu-vr" ''
          echo "Setting AMD card to VR mode..."
          echo "manual" | sudo tee /sys/class/drm/renderD128/device/power_dpm_force_performance_level
          echo "4" | sudo tee /sys/class/drm/renderD128/device/pp_power_profile_mode
          echo "Done!"
        '')
        # As per https://github.com/alvr-org/ALVR/wiki/ALVR-wired-setup-(ALVR-over-USB)
        (writeShellScriptBin "alvr-usb" ''
          ${adb} start-server
          ${adb} forward tcp:9943 tcp:9943
          ${adb} forward tcp:9944 tcp:9944
        '')
        pkgs-xr.wayvr-dashboard
        install-wayvr-dashboard
        wlx-overlay-s
        android-tools # adb for standalone headsets
        bs-manager
        # immersed
        xrgears
      ];

      # Auto-install on activation, in case the path changed.
      system.userActivationScripts.install-wayvr-dashboard = "${toString install-wayvr-dashboard}/bin/install-wayvr-dashboard";

    })

    (lib.mkIf (cfg.profiles.gaming.vr.enable && cfg.profiles.gaming.vr.patchAmdgpu) {
      # As per https://wiki.nixos.org/wiki/Linux_kernel#Patching_a_single_In-tree_kernel_module
      boot.extraModulePackages = [
        (pkgs.callPackage ../../../pkgs/amdgpu-kernel-module.nix {
          patches = [
            # As per https://wiki.nixos.org/wiki/VR#Patching_AMDGPU_to_allow_high_priority_queues
            (pkgs.fetchpatch {
              name = "cap_sys_nice_begone.patch";
              url = "https://github.com/Frogging-Family/community-patches/raw/master/linux61-tkg/cap_sys_nice_begone.mypatch";
              hash = "sha256-Y3a0+x2xvHsfLax/uwycdJf3xLxvVfkfDVqjkxNaYEo=";
            })
          ];
          kernel = config.boot.kernelPackages.kernel;
        })
      ];
    })

    (lib.mkIf (cfg.profiles.gaming.vr.enable && cfg.profiles.gaming.vr.monado.enable) {

      # As per https://wiki.nixos.org/wiki/VR#Monado
      # To use with Steam games, use the following:
      # env PRESSURE_VESSEL_FILESYSTEMS_RW=$XDG_RUNTIME_DIR/monado_comp_ipc %command%
      services.monado = {
        enable = true;
        highPriority = true;
        defaultRuntime = cfg.profiles.gaming.vr.monado.default;
      };

      gradient.profiles.gaming.vr.steam.pressure-vessel-filesystems-rw = [ "$XDG_RUNTIME_DIR/monado_comp_ipc" ];

      systemd.user.services.monado.environment = {
        # Configure environment as needed here...
        # Might prevent a crash on AMDGPU?
        XRT_DISTORTION_MIP_LEVELS = "1";
      };

      # See https://wiki.nixos.org/wiki/VR#Hand_Tracking for setup
      programs.git = {
        enable = true;
        lfs.enable = true;
      };

    })

    (lib.mkIf (cfg.profiles.gaming.vr.enable && cfg.profiles.gaming.vr.wivrn.enable) {

      environment.systemPackages = with pkgs; [
        # Script as per https://github.com/WiVRn/WiVRn?tab=readme-ov-file#how-do-i-use-a-wired-connection
        (writeShellScriptBin "wivrn-usb" ''
          ${adb} start-server
          ${adb} reverse tcp:9757 tcp:9757
          ${adb} shell am start -a android.intent.action.VIEW -d "wivrn+tcp://localhost" ${cfg.profiles.gaming.vr.wivrn.androidId}
        '')
      ];

      # As per https://wiki.nixos.org/wiki/VR#WiVRn
      # To use with Steam games, use the following:
      # env PRESSURE_VESSEL_FILESYSTEMS_RW=$XDG_RUNTIME_DIR/wivrn/comp_ipc %command%
      services.wivrn = {
        enable = true;
        package = pkgs.stable.wivrn;
        openFirewall = true;

        # Write information to /etc/xdg/openxr/1/active_runtime.json, VR applications
        # will automatically read this and work with WiVRn (Note: This does not currently
        # apply for games run in Valve's Proton)
        defaultRuntime = cfg.profiles.gaming.vr.wivrn.default;

        # Run WiVRn as a systemd service on startup
        autoStart = true;

        monadoEnvironment = {
          # Might prevent a crash on AMDGPU?
          XRT_DISTORTION_MIP_LEVELS = "1";
        };

        # Config for WiVRn (https://github.com/WiVRn/WiVRn/blob/master/docs/configuration.md)
        config = {
          enable = true;
          json = {
            # 0.5x foveation scaling
            scale = 0.5;
            # 50 Mb/s
            bitrate = 50000000;
            # Do not manage the OpenVR configuration, use openvr-runtime script.
            openvr-compat-path = null;
            encoders = [
              {
                encoder = "vaapi";
                codec = "h265";
                device = "/dev/dri/renderD128";
                # 1.0 x 1.0 scaling
                width = 1.0;
                height = 1.0;
                offset_x = 0.0;
                offset_y = 0.0;
              }
            ];
          };
        };
      };

      gradient.profiles.gaming.vr.steam.pressure-vessel-filesystems-rw = [ "$XDG_RUNTIME_DIR/wivrn/comp_ipc" ];

    })

  ];

}