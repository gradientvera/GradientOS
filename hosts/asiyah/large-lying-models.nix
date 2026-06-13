{ config, self, pkgs, ports, lib, ... }:
let
  ikCacheDir = "/var/cache/ik-llama-cpp";
  cacheDir = "/var/cache/llama-cpp";
  ports = config.gradient.currentHost.ports;
in
{

  systemd.tmpfiles.settings."10-llama-cpp.conf" = {
    ${ikCacheDir}.d.mode = "0777";
    "${ikCacheDir}/slots".d.mode = "0777";
    "${cacheDir}/slots".d.mode = "0777";
  };

  systemd.services.llama-cpp = {
    serviceConfig.LimitMEMLOCK = "infinity"; # wew lass
    environment.LLAMA_CACHE = cacheDir;
    environment.MESA_SHADER_CACHE_DIR = cacheDir;
  };

  services.llama-cpp = {
    enable = true;
    package = pkgs.master.llama-cpp-vulkan;
    settings = {
      host = "0.0.0.0";
      port = ports.llama-cpp;

      # Try to keep threads on a single CPU (asiyah has two)
      numa = "isolate";
      
      slot-save-path = "/var/cache/llama-cpp/slots";

      hf-repo = "Jackrong/Qwen3.5-2B-Claude-4.6-Opus-Reasoning-Distilled-GGUF:Q6_K";
      alias = "Qwen3.5-2B,hass-default,frigate-default";
      temp = "0.7";
      top-p = "0.8";
      top-k = "20";
      min-p = "0.0";
      presence-penalty = "1.5";
      repeat-penalty = "1.0";
      reasoning = "on";
      reasoning-budget = "128";
      reasoning-budget-message = "\"... Reasoning budget exhausted. I should have enough to answer now.\"";
      /*t = "18";
      tb = "18";
      b = "2048";
      ub = "1024";*/
      /*ctk = "q4_0";
      ctv = "q4_0";*/
      flash-attn = "on";
      fit = "on";
      jinja = "";
      mmproj-auto = "";
      no-mmproj-offload = "";
      spec-default = "";
      context-shift = "";
    };
  };

  systemd.services."container@ik-llama-cpp".serviceConfig.LimitMEMLOCK = "infinity"; # wew lass
  containers.ik-llama-cpp = {
    autoStart = true;
    bindMounts."/var/cache/llama-cpp" = { hostPath = ikCacheDir; isReadOnly = false; };
    extraFlags = [
      # See https://github.com/NixOS/nixpkgs/pull/388409
      # Read-only root with tmpfs overlay
      "--volatile=overlay"
      # Let host access this containers' logs
      "--link-journal=try-host"
      # Allows mlock flag below to work
      "--system-call-filter=@memlock"
    ];
    config = { ... }:
    {
      nixpkgs.pkgs = pkgs;
      systemd.services.llama-cpp.serviceConfig.LimitMEMLOCK = "infinity"; # once again, wew lass
      # ik-llama.cpp does not download mmproj
      systemd.services.llama-cpp.preStart = ''
        if [ ! -f "${cacheDir}/mmproj-F16.gguf" ]; then
          pushd ${cacheDir}
          ${toString pkgs.curl}/bin/curl -L -O https://huggingface.co/unsloth/Qwen3.5-35B-A3B-MTP-GGUF/resolve/main/mmproj-F16.gguf
          popd
        fi
      '';
      services.llama-cpp = {
        enable = true;
        package = self.inputs.ik-llama-cpp.packages.x86_64-linux.mpi-cpu;
        settings = {
          host = "0.0.0.0";
          port = ports.ik-llama-cpp;
          numa = "isolate";
          hf-repo = "unsloth/Qwen3.5-35B-A3B-MTP-GGUF";
          hf-file = "Qwen3.5-35B-A3B-UD-Q4_K_M.gguf";
          mmproj = "${cacheDir}/mmproj-F16.gguf";
          alias = "Qwen3.5-35B_A3B-CPU";
          spec-type = "mtp:n_max=6,p_min=0.0";
          merge-up-gate-experts = "";
          spec-autotune = "";
          parallel = "1";
          cpu-moe = "";
          slot-save-path = "/var/cache/llama-cpp/slots";
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
          cache-type-v = "f16";
          flash-attn = "on";
          mla-use = "3";
          jinja = "";
          no-fused-moe = "";
          scheduler_async = "";
          no-mmproj-offload = "";
          no-kv-offload = "";
          run-time-repack = "";
          split-mode-f32 = "";
          split-mode-graph-scheduling = "";
          mlock = "";
        };
      };
    };
  };

  environment.systemPackages = [
    config.services.llama-cpp.package
  ];

  services.open-webui = {
    enable = true;
    port = ports.open-webui;
    environment = {
      WEBUI_AUTH = "False";

      HOME = "/var/lib/open-webui";

      ENABLE_OPENAI_API = "true";
      OPENAI_API_BASE_URL = "http://127.0.0.1:${toString ports.llama-cpp}/v1";

      ENABLE_RAG_WEB_SEARCH = "True";
      RAG_WEB_SEARCH_ENGINE = "searxng";
      RAG_WEB_SEARCH_RESULT_COUNT = "3";
      RAG_WEB_SEARCH_CONCURRENT_REQUESTS = "10";
      SEARXNG_QUERY_URL = "http://127.0.0.1:${toString ports.searx}/search?q=<query>";

      ENABLE_WEBSOCKET_SUPPORT = "true";
      WEBSOCKET_MANAGER = "redis";
      WEBSOCKET_REDIS_URL = "redis://127.0.0.1:${toString ports.redis-open-webui}/0";
      REDIS_KEY_PREFIX = "open-webui";

      # what's the fucking point of hosting this shit locally otherwise??
      DO_NOT_TRACK = "True";
      SCARF_NO_ANALYTICS = "True";
      ANONYMIZED_TELEMETRY = "False";
    };
  };

  services.redis.servers.open-webui = {
    enable = true;
    openFirewall = false;
    databases = 1;
    port = ports.redis-open-webui;
  };

  systemd.services.open-webui = {
    wants = [ "redis-open-webui.service" "searx.service" ];
    after = [ "redis-open-webui.service" "searx.service" "llama-cpp.service" ];
  };

  networking.firewall.interfaces.gradientnet.allowedTCPPorts = [
    ports.llama-cpp
    ports.ik-llama-cpp
  ];

  networking.firewall.interfaces.podman0.allowedTCPPorts = [
    ports.llama-cpp
    ports.ik-llama-cpp
  ];

}