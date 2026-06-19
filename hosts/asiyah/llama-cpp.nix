{ config, self, pkgs, ports, system, lib, ... }:
let
  stateDir = "/var/lib/llama-swap";
in
{

  boot.kernel.sysctl."kernel.numa_balancing" = 0;

  systemd.tmpfiles.settings."10-llama-swap.conf" = 
  let
    rule = { mode = "750"; };
  in
  {
    # Just make a directory per model...
    "${stateDir}/1".d = rule;
    "${stateDir}/2".d = rule;
  };

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
        llama-cpp-server = "${self.inputs.llama-cpp.packages.${system}.vulkan}/bin/llama-server";
        # see https://github.com/ikawrakow/ik_llama.cpp/blob/main/examples/server/README.md
        ik-llama-cpp-server = "${self.inputs.ik-llama-cpp.packages.${system}.vulkan}/bin/llama-server";
        mkCmd = { serverPath ? llama-cpp-server, ... }@args: "${serverPath} ${lib.cli.toGNUCommandLineShell {} (removeAttrs args ["serverPath"])}";
      in
      {

        "Qwen3.5-2B-GPU" = {
          aliases = [ "hass-default" ];
          cmd = mkCmd {
            serverPath = llama-cpp-server;
            port = "\${PORT}";
            hf-repo = "Jackrong/Qwen3.5-2B-Claude-4.6-Opus-Reasoning-Distilled-GGUF:Q6_K";
            temp = "0.7";
            top-p = "0.8";
            top-k = "20";
            min-p = "0.0";
            presence-penalty = "1.5";
            repeat-penalty = "1.0";
            reasoning = "on";
            reasoning-budget = "128";
            reasoning-budget-message = "\"... Reasoning budget exhausted. I should have enough to answer now.\"";
            numa = "isolate";
            threads = "18";
            threads-batch = "18";
            batch-size = "2048";
            ubatch-size = "1024";
            fit = "on";
            flash-attn = "on";
            jinja = true;
            mmproj-auto = true;
            no-mmproj-offload = true;
            spec-default = true;
            context-shift = true;
            slot-save-path = "${stateDir}/1";
          };
          env = [ "LLAMA_CACHE=${stateDir}/1" "MESA_SHADER_CACHE_DIR=${stateDir}/1" ];
        };

        "Qwen3.5-35B-A3B-CPU" = {
          aliases = [ "frigate-default" ];
          cmd = mkCmd {
            serverPath = ik-llama-cpp-server;
            port = "\${PORT}";
            numa = "isolate";
            hf-repo = "unsloth/Qwen3.5-35B-A3B-MTP-GGUF";
            hf-file = "Qwen3.5-35B-A3B-Q8_0.gguf";
            mmproj = "${stateDir}/2/mmproj-F16.gguf";
            spec-type = "mtp:n_max=1,p_min=0.0";
            parallel = "1";
            gpu-layers = "0";
            temp = "1.0";
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
            cache-type-k = "q8_0";
            cache-type-v = "q8_0";
            flash-attn = "on";
            jinja = true;
            no-mmproj-offload = true;
            no-kv-offload = true;
            run-time-repack = true;
            mlock = true;
            slot-save-path = "${stateDir}/2";
          };
          env = [ "LLAMA_CACHE=${stateDir}/2" "MESA_SHADER_CACHE_DIR=${stateDir}/2" ];
        };

      };
      hooks.on_startup.preload = [
        "Qwen3.5-2B-GPU"
        "Qwen3.5-35B-A3B-CPU"
      ];

    };
  };

  systemd.services.llama-swap = {
    # To put downloaded models somewhere
    serviceConfig = {
      StateDirectory = "llama-swap";
      RuntimeDirectory = "llama-swap";
      LimitMEMLOCK = "infinity"; # wew lass
    };
    # Download any missing files -- mostly for ik_llama.cpp mmproj downloads
    preStart = ''
      if [ ! -f "${stateDir}/2/mmproj-F16.gguf" ]; then
        pushd ${stateDir}/2
        ${toString pkgs.curl}/bin/curl -L -O https://huggingface.co/unsloth/Qwen3.5-35B-A3B-MTP-GGUF/resolve/main/mmproj-F16.gguf
        popd
      fi
    '';
  };

  networking.firewall.interfaces.gradientnet.allowedTCPPorts = [
    ports.llama-swap
  ];

  networking.firewall.interfaces.podman0.allowedTCPPorts = [
    ports.llama-swap
  ];

}