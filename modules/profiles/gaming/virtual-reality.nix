{ config, lib, pkgs, ... }:
let
  cfg = config.gradient;
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
          xrizerVr = mkOpenVr "xrizer.vrpath" "${pkgs.xrizer}/lib/xrizer";
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

          xrizer: _clean (_link "${toString xrizerVr}")
            @echo "Set XRizer as the OpenVR runtime."

        '')
        (let
          monadoXr = "${pkgs.monado}/share/openxr/1/openxr_monado.json";
          wivrnXr = "${pkgs.wivrn}/share/openxr/1/openxr_wivrn.json";
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

          wivrn: _clean (_link "${wivrnXr}")
            @echo "Set WiVRn as the OpenXR runtime."

        '')
      ];

    })

    (lib.mkIf (cfg.profiles.gaming.vr.enable && cfg.profiles.gaming.vr.installUtilities) {

      programs.alvr = {
        enable = true;
        openFirewall = true;
      };

      environment.systemPackages = with pkgs; [
        (pkgs.writeShellScriptBin "amdgpu-vr" ''
          echo "Setting AMD card to VR mode..."
          echo "4" > /sys/class/drm/renderD128/device/pp_power_profile_mode
          echo "Done!"
        '')
        wlx-overlay-s
        bs-manager
        immersed
        xrgears
      ];

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
        # Configure as needed here...
      };

      # See https://wiki.nixos.org/wiki/VR#Hand_Tracking for setup
      programs.git = {
        enable = true;
        lfs.enable = true;
      };

    })

    (lib.mkIf (cfg.profiles.gaming.vr.enable && cfg.profiles.gaming.vr.wivrn.enable) {

      # As per https://wiki.nixos.org/wiki/VR#WiVRn
      # To use with Steam games, use the following:
      # env PRESSURE_VESSEL_FILESYSTEMS_RW=$XDG_RUNTIME_DIR/wivrn/comp_ipc %command%
      services.wivrn = {
        enable = true;
        openFirewall = true;

        # Write information to /etc/xdg/openxr/1/active_runtime.json, VR applications
        # will automatically read this and work with WiVRn (Note: This does not currently
        # apply for games run in Valve's Proton)
        defaultRuntime = cfg.profiles.gaming.vr.wivrn.default;

        # Run WiVRn as a systemd service on startup
        autoStart = true;

        # Config for WiVRn (https://github.com/WiVRn/WiVRn/blob/master/docs/configuration.md)
        config = {
          enable = true;
          json = {
            # 1.0x foveation scaling
            scale = 1.0;
            # 100 Mb/s
            bitrate = 100000000;
            encoders = [
              {
                encoder = "vaapi";
                codec = "h265";
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