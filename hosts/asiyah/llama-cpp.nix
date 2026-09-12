{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (config.gradient.presets.llama-swap)
    mkCmd
    servers
    stateDir
    ;
in
{

  # Can harm performance with ik_llama.cpp CPU inference
  boot.kernel.sysctl."kernel.numa_balancing" = 0;

  gradient.presets.llama-swap = {
    enable = true;
    hfTokenPath = config.sops.secrets.huggingface-readonly-token.path;
    openFirewallInterfaces = [
      "gradientnet"
      "podman0"
    ];

    models = {
      "nomic-embed-text" = {
        repo = "nomic-ai/nomic-embed-text-v1.5-GGUF";
        includes = [ "nomic-embed-text-v1.5.Q8_0.gguf" ];
        dir = "nomic-embed-text";

        settings = {
          ttl = 300;
          cmd = mkCmd {
            serverPath = servers.vulkan;
            port = "$1";
            model = "${stateDir}/nomic-embed-text/nomic-embed-text-v1.5.Q8_0.gguf";
            embedding = true;
            pooling = "mean";
            ctx-size = "2048";
            batch-size = "2048";
            ubatch-size = "2048";
          };
        };
      };

      "Bonsai-27B-GPU" = {
        repo = "prism-ml/Bonsai-27B-gguf";
        includes = [
          "Bonsai-27B-Q1_0.gguf"
          "Bonsai-27B-mmproj-Q8_0.gguf"
        ];
        dir = "Bonsai-27B";

        settings = {
          aliases = [
            "hass-default"
            "frigate-default"
          ];
          cmd = mkCmd {
            serverPath = servers.vulkan;
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
        };
      };
    };
  };

  services.llama-swap.settings.groups = {
    embeddings = {
      swap = false;
      exclusive = false;
      members = [ "nomic-embed-text" ];
    };
    gpu = {
      swap = false;
      exclusive = false;
      members = [ "Bonsai-27B-GPU" ];
    };
  };

}
