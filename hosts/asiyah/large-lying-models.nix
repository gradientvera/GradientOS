{ config, self, pkgs, ports, lib, ... }:
let
  modelsDir = "/var/lib/llama-cpp/models";
  ports = config.gradient.currentHost.ports;
in
{

  systemd.services.llama-cpp = {
    serviceConfig.LimitMEMLOCK = "infinity"; # wew lass
    preStart = "mkdir -p ${modelsDir}";
    environment.LLAMA_CACHE = "/var/cache/llama-cpp";
    environment.MESA_SHADER_CACHE_DIR = "/var/cache/llama-cpp";
  };

  services.llama-cpp = {
    inherit modelsDir;
    enable = true;
    host = "127.0.0.1";
    port = ports.llama-cpp;
    package = pkgs.master.llama-cpp-vulkan;
    extraFlags = [
        # Only one model loaded at max
        "--models-max" "1"


        "--numa" "isolate"
        
        # Load models automatically
        "--models-autoload"

        # Stay active for 10 minutes, then sleep...
        "--sleep-idle-seconds" "600"
    ];
    modelsPreset."Qwen3.5-9B-Q4_K_M" = {
      hf = "unsloth/Qwen3.5-9B-GGUF:Q4_K_M";
      temp = "0.7";
      top-p = "0.8";
      top-k = "20";
      min-p = "0.0";
      presence-penalty = "1.5";
      repeat-penalty = "1.0";
      reasoning = "off";
      t = "18";
      tb = "18";
      b = "2048";
      ub = "1024";
      ctk = "q4_0";
      ctv = "q4_0";
      ctx-size = "8192";
      flash-attn = "on";
      fit = "on";
      mmproj-auto = "on";
      no-mmproj-offload = "on";
      spec-default = "on";
      context-shift = "on";
    };
  };

  services.open-webui = {
    enable = true;
    port = ports.open-webui;
    environment = {
      WEBUI_AUTH = "False";

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
  ];

  networking.firewall.interfaces.podman0.allowedTCPPorts = [
    ports.llama-cpp
  ];

}