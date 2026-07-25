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
  stateDir = "/var/lib/llama-swap";
in
{

  # Can harm performance with ik_llama.cpp CPU inference
  boot.kernel.sysctl."kernel.numa_balancing" = 0;

  # Create a folder under state dir for each instance
  systemd.tmpfiles.settings."10-llama-swap.conf" = (
    lib.mapAttrs' (
      n: v:
      lib.nameValuePair ("${stateDir}/${n}") {
        d = {
          mode = "750";
          user = "nobody";
          group = "nogroup";
        };
      }
    ) config.services.llama-swap.settings.models
  );

  services.llama-swap = {
    enable = true;
    listenAddress = "0.0.0.0";
    port = ports.llama-swap;
    # see https://github.com/mostlygeek/llama-swap/blob/main/docs/configuration.md
    settings = {
      includeAliasesInList = true; # duplicate model listing for aliases
      healthCheckTimeout = 720; # if a model isn't cached it may take a long time to dl
      sendLoadingState = false;
      logToStdout = "both"; # log proxy and upstream processes
      startPort = 20000; # port allocation start
      globalTTL = 0; # by default, never unload models

      models =
        let
          # see https://github.com/ggml-org/llama.cpp/blob/master/tools/server/README.md
          llama-cpp-vulkan-server = "${self.inputs.llama-cpp.packages.${system}.vulkan}/bin/llama-server";
          # see https://github.com/ikawrakow/ik_llama.cpp/blob/main/examples/server/README.md
          ik-llama-cpp-cpu-server = "${self.inputs.ik-llama-cpp.packages.${system}.mpi-cpu}/bin/llama-server";
          mkCmd =
            {
              serverPath ? llama-cpp-vulkan-server,
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
              cmdArgs = mkLlamaCommandLine (removeAttrs args [ "serverPath" ]);
              shellArgs = builtins.concatStringsSep " " cmdArgs;
              script = pkgs.writeShellScript "llama-swap-cmd.sh" "${serverPath} ${shellArgs}";
            in
            "${script} \${PORT}";
        in
        {

          "Bonsai-27B-GPU" = {
            aliases = [
              "hass-default"
              "frigate-default"
            ];
            cmd = mkCmd {
              serverPath = llama-cpp-vulkan-server;
              port = "$1";
              model = "${stateDir}/Bonsai-27B/Bonsai-27B-Q1_0.gguf";
              mmproj = "${stateDir}/Bonsai-27B/Bonsai-27B-mmproj-Q8_0.gguf";
              temp = "0.7";
              top-p = "0.95";
              top-k = "20";
              reasoning = "on";
              reasoning-budget = "2048";
              reasoning-budget-message = "\"... Reasoning budget exhausted. I should have enough to answer now.\"";
              numa = "isolate";
              threads = "18";
              threads-batch = "18";
              cache-type-k = "q4_0";
              cache-type-v = "q4_0";
              flash-attn = "on";
              cache-ram = "${toString (1024 * 64)}";
              ctx-checkpoints = "128";
              reasoning-preserve = true;
              jinja = true;
              mmproj-auto = true;
              no-mmproj-offload = true;
              spec-default = true;
              context-shift = true;
              slot-save-path = "${stateDir}/Bonsai-27B-GPU";
            };
            env = [
              "LLAMA_CACHE=${stateDir}/Bonsai-27B-GPU"
              "MESA_SHADER_CACHE_DIR=${stateDir}/Bonsai-27B-GPU"
            ];
          };

        };

      hooks.on_startup.preload = [
        "Bonsai-27B-GPU"
      ];
    };
  };

  systemd.services.llama-swap = {
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];

    # To put downloaded models somewhere
    serviceConfig = {
      # For hf hub
      CacheDirectory = "llama-swap";
      StateDirectory = "llama-swap";
      LimitMEMLOCK = "infinity"; # wew lass
      TimeoutStartSec = "15min"; # listen, these things take time to download alright?
      LoadCredential = "hf-token:${config.sops.secrets.huggingface-readonly-token.path}";
    };
    # Download models beforehand (will not redownload unless missing)
    path = [ pkgs.python313Packages.huggingface-hub ];
    preStart = ''
      export HF_HOME=/var/cache/llama-swap
      TOKEN=$(cat $CREDENTIALS_DIRECTORY/hf-token)

      hf download prism-ml/Bonsai-27B-gguf \
        --include "Bonsai-27B-Q1_0.gguf" \
        --include "Bonsai-27B-mmproj-Q8_0.gguf" \
        --local-dir "${stateDir}/Bonsai-27B" \
        --token $TOKEN
    '';
  };

  networking.firewall.interfaces.gradientnet.allowedTCPPorts = [
    ports.llama-swap
  ];

  networking.firewall.interfaces.podman0.allowedTCPPorts = [
    ports.llama-swap
  ];

}
