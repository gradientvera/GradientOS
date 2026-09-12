{
  config,
  self,
  pkgs,
  ports,
  system,
  lib,
  ...
}:
let
  cfg = config.gradient.presets.llama-swap;
  port = ports.llama-swap;
in
{

  options.gradient.presets.llama-swap = {
    enable = lib.mkEnableOption "the llama-swap preset";

    models = lib.mkOption {
      description = ''
        Models to register with llama-swap.
        Each model's `settings` is passed to
        `services.llama-swap.settings.models.<name>`, see
        https://github.com/mostlygeek/llama-swap/blob/main/docs/configuration.md
      '';
      default = { };
      type = lib.types.attrsOf (
        lib.types.submodule (
          { name, ... }:
          {
            options = {
              repo = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = ''
                  Hugging Face repository to pre-download in the unit's preStart script. (null skips downloading)
                '';
              };

              includes = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [ ];
                description = ''
                  `--include` globs for the hf download. Case-sensitive.
                '';
              };

              dir = lib.mkOption {
                type = lib.types.str;
                default = name;
                defaultText = "model name";
                description = "Subdirectory of the llama-swap state dir to download into.";
              };

              settings = lib.mkOption {
                type = lib.types.attrsOf lib.types.raw;
                default = { };
                description = ''
                  llama-swap model entry (cmd, aliases, env, ...).
                  `env` defaults to pointing LLAMA_CACHE and MESA_SHADER_CACHE_DIR
                  at the model's own state dir subdirectory.
                '';
              };
            };
          }
        )
      );
    };

    preload = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Model names for llama-swap's hooks.on_startup.preload.";
    };

    openFirewallInterfaces = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Network interfaces to allow the llama-swap port on.";
    };

    hfTokenPath = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      example = "config.sops.secrets.huggingface-readonly-token.path";
      description = ''
        Path to an (optionally sops-managed) Hugging Face access token, passed
        to the unit as a LoadCredential and given to hf downloads.
        null runs downloads unauthenticated.
      '';
    };

    stateDir = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      default = "/var/lib/llama-swap";
      description = "Base directory for model files, caches and slot saves.";
    };

    servers = {
      vulkan = lib.mkOption {
        type = lib.types.str;
        readOnly = true;
        description = "Store path of the llama.cpp Vulkan `llama-server` binary.";
      };
      ik-cpu = lib.mkOption {
        type = lib.types.str;
        readOnly = true;
        description = "Store path of the ik_llama.cpp MPI CPU `llama-server` binary.";
      };
      # mainline llama.cpp CPU (BLAS) build — current arch support (no fork lag)
      mainline-cpu = lib.mkOption {
        type = lib.types.str;
        readOnly = true;
        description = "Store path of the mainline llama.cpp CPU `llama-server` binary.";
      };
      # mainline llama.cpp ROCm build — full-VRAM GPU inference on AMD cards
      rocm = lib.mkOption {
        type = lib.types.str;
        readOnly = true;
        description = "Store path of the mainline llama.cpp ROCm `llama-server` binary.";
      };
    };

    mkCmd = lib.mkOption {
      type = lib.types.raw;
      readOnly = true;
      description = ''
        `mkCmd { serverPath ? servers.vulkan, ... }: string`
        Builds a llama-swap `cmd` string from llama-server arguments, see
        https://github.com/ggml-org/llama.cpp/blob/master/tools/server/README.md
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = lib.mapAttrsToList (name: m: {
      assertion = m.repo == null || m.includes != [ ];
      message =
        "gradient.presets.llama-swap.models.${name}: repo is set but includes is empty — "
        + "hf would silently download nothing.";
    }) cfg.models;

    gradient.presets.llama-swap = {
      servers = {
        # see https://github.com/ggml-org/llama.cpp/blob/master/tools/server/README.md
        vulkan = "${self.inputs.llama-cpp.packages.${system}.vulkan}/bin/llama-server";
        # see https://github.com/ikawrakow/ik_llama.cpp/blob/main/examples/server/README.md
        ik-cpu = "${self.inputs.ik-llama-cpp.packages.${system}.mpi-cpu}/bin/llama-server";
        mainline-cpu = "${self.inputs.llama-cpp.packages.${system}.default}/bin/llama-server";
        rocm = "${self.inputs.llama-cpp.packages.${system}.rocm}/bin/llama-server";
      };

      mkCmd =
        {
          serverPath ? config.gradient.presets.llama-swap.servers.vulkan,
          # Command prefix, e.g. "numactl --interleave=all " for multi-socket CPU inference
          prefix ? "",
          ...
        }@args:
        let
          # The following functions will generate a command like this:
          # "llama-server --reasoning on --threads 18 [...]"
          # llama-cpp is a bit weird with arguments, always try to use long-format args.
          mkLlamaCommandLine = lib.cli.toCommandLine (optionName: {
            option = if (lib.stringLength optionName > 1) then "--${optionName}" else "-${optionName}";
            sep = " ";
            explicitBool = false;
          });
          cmdArgs = mkLlamaCommandLine (
            removeAttrs args [
              "serverPath"
              "prefix"
            ]
          );
          shellArgs = builtins.concatStringsSep " " cmdArgs;
          script = pkgs.writeShellScript "llama-swap-cmd.sh" "${prefix}${serverPath} ${shellArgs}";
        in
        "${script} \${PORT}";
    };

    services.llama-swap = {
      enable = true;
      listenAddress = lib.mkDefault "0.0.0.0";
      port = lib.mkDefault port;
      settings = {
        includeAliasesInList = lib.mkDefault true; # duplicate model listing for aliases
        healthCheckTimeout = lib.mkDefault 720; # if a model isn't cached it may take a long time to dl
        sendLoadingState = lib.mkDefault false;
        logToStdout = lib.mkDefault "both"; # log proxy and upstream processes
        startPort = lib.mkDefault 20000; # port allocation start
        globalTTL = lib.mkDefault 120; # by default, unload models after 2 minutes

        models = lib.mapAttrs (
          name: m:
          {
            env = lib.mkDefault [
              "LLAMA_CACHE=${cfg.stateDir}/${name}"
              "MESA_SHADER_CACHE_DIR=${cfg.stateDir}/${name}"
            ];
          }
          // m.settings
        ) cfg.models;

        hooks.on_startup.preload = cfg.preload;
      };
    };

    # Create a folder under the state dir for each instance and download target
    systemd.tmpfiles.settings."10-llama-swap.conf" =
      let
        dirs = lib.unique ((lib.attrNames cfg.models) ++ (map (m: m.dir) (lib.attrValues cfg.models)));
        mkDir = dir: {
          d = {
            mode = "750";
            user = "nobody";
            group = "nogroup";
          };
        };
      in
      (lib.listToAttrs (map (dir: lib.nameValuePair "${cfg.stateDir}/${dir}" (mkDir dir)) dirs))
      // {
        # hf's HF_HOME cache lives outside StateDirectory; without this, the
        # preStart `hf download` runs as nobody against root-owned /var/cache
        # and fails to create it on fresh hosts (the amsiyah fix "chown
        # nobody:nogroup /var/cache/llama-swap" was a manual make of this).
        "/var/cache/llama-swap" = mkDir "";
      };

    systemd.services.llama-swap = {
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];

      serviceConfig = {
        # To put downloaded models somewhere
        StateDirectory = "llama-swap";
        LimitMEMLOCK = "infinity"; # wew lass
        TimeoutStartSec = "15min"; # listen, these things take time to download alright?
      }
      // lib.optionalAttrs (cfg.hfTokenPath != null) {
        LoadCredential = "hf-token:${cfg.hfTokenPath}";
      };

      # Download models beforehand (will not redownload unless missing)
      path = [ pkgs.python313Packages.huggingface-hub ];
      preStart =
        let
          downloadBlocks = lib.mapAttrsToList (
            _: m:
            lib.optionalString (m.repo != null) ''
              hf download ${m.repo} \
                ${lib.concatMapStringsSep " \\\n              " (glob: ''--include "${glob}"'') m.includes} \
                --local-dir "${cfg.stateDir}/${m.dir}"${
                  if (cfg.hfTokenPath != null) then " \\\n              --token $TOKEN" else ""
                }
            ''
          ) cfg.models;
        in
        ''
          export HF_HOME=/var/cache/llama-swap
          ${lib.optionalString (cfg.hfTokenPath != null) ''
            TOKEN=$(cat $CREDENTIALS_DIRECTORY/hf-token)
          ''}
          ${lib.concatStringsSep "\n" downloadBlocks}
        '';
    };

    networking.firewall.interfaces = lib.genAttrs cfg.openFirewallInterfaces (_: {
      allowedTCPPorts = [ port ];
    });
  };

}
