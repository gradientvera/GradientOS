{ config, self, pkgs, ports, system, lib, ... }:
let
  stateDir = "/var/lib/llama-swap";
in
{

  # Can harm performance with ik_llama.cpp CPU inference
  boot.kernel.sysctl."kernel.numa_balancing" = 0;

  # Create a folder under state dir for each instance
  systemd.tmpfiles.settings."10-llama-swap.conf" = 
    (lib.mapAttrs' (n: v: lib.nameValuePair ("${stateDir}/${n}") { d = { mode = "750"; user = "nobody"; group = "nogroup"; }; }) config.services.llama-swap.settings.models);

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

      models = let
        # see https://github.com/ggml-org/llama.cpp/blob/master/tools/server/README.md
        llama-cpp-vulkan-server = "${self.inputs.llama-cpp.packages.${system}.vulkan}/bin/llama-server";
        # see https://github.com/ikawrakow/ik_llama.cpp/blob/main/examples/server/README.md
        ik-llama-cpp-cpu-server = "${self.inputs.ik-llama-cpp.packages.${system}.mpi-cpu}/bin/llama-server";
        mkCmd = { serverPath ? llama-cpp-vulkan-server, ... }@args: "${serverPath} ${lib.cli.toGNUCommandLineShell {} (removeAttrs args ["serverPath"])}";
      in
      {

        "Bonsai-27B-GPU" = {
          aliases = [ "hass-default" "frigate-default" ];
          cmd = mkCmd {
            serverPath = llama-cpp-vulkan-server;
            port = "\${PORT}";
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
            jinja = true;
            mmproj-auto = true;
            no-mmproj-offload = true;
            spec-default = true;
            context-shift = true;
            slot-save-path = "${stateDir}/Bonsai-27B-GPU";
          };
          env = [ "LLAMA_CACHE=${stateDir}/Bonsai-27B-GPU" "MESA_SHADER_CACHE_DIR=${stateDir}/Bonsai-27B-GPU" ];
        };

        /*"Bonsai-27B-CPU" = {
          aliases = [ "frigate-default" ];
          cmd = mkCmd {
            serverPath = ik-llama-cpp-cpu-server;
            port = "\${PORT}";
            numa = "isolate";
            model = "${stateDir}/Bonsai-27B/Bonsai-27B-Q1_0.gguf";
            mmproj = "${stateDir}/Bonsai-27B/Bonsai-27B-mmproj-Q8_0.gguf";
            parallel = "1";
            gpu-layers = "0";
            temp = "0.7";
            top-p = "0.95";
            top-k = "20";
            min-p = "0.00";
            batch-size = "1024";
            ubatch-size = "1024";
            presence-penalty = "1.5";
            repeat-penalty = "1.0";
            reasoning = "on";
            reasoning-budget = "128";
            reasoning-budget-message = "\"... Reasoning budget exhausted. I should have enough to answer now.\"";
            threads = "18";
            cache-type-k = "q4_0";
            cache-type-v = "q4_0";
            flash-attn = "on";
            jinja = true;
            no-mmproj-offload = true;
            no-kv-offload = true;
            run-time-repack = true;
            mlock = true;
            slot-save-path = "${stateDir}/Bonsai-27B-CPU";
          };
          env = [ "LLAMA_CACHE=${stateDir}/Bonsai-27B-CPU" "MESA_SHADER_CACHE_DIR=${stateDir}/Bonsai-27B-CPU" ];
        };*/

      };

      # wtf is this?
      matrix = {
        vars = {
          a = "Bonsai-27B-GPU";
          #b = "Bonsai-27B-CPU";
        };
        evict_costs = {
          a = 10; # small model on the GPU, loads fast
          #b = 50; # large model on the CPU, loads slowly
        };
        sets = {
          # models that run on the GPU
          gpu = "(a)";

          # models that run on the CPU
          #cpu = "(b)";

          # run models on both the GPU and CPU
          #final = "+gpu & +cpu";
        };
      };

      hooks.on_startup.preload = [
        "Bonsai-27B-GPU"
        #"Bonsai-27B-CPU"
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