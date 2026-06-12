{ config, self, pkgs, ports, lib, ... }:
let
  cacheDir = "/var/cache/llama-cpp";
  ports = config.gradient.currentHost.ports;
in
{

  systemd.tmpfiles.settings."10-llama-cpp-slot-cache.conf"."${cacheDir}/slots".d.mode = "0777";

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
      # Only one model loaded at max
      models-max = "1";
      # Try to keep threads on a single CPU (asiyah has two)
      numa = "isolate";
      # Load models automatically
      models-autoload = "";
      # Stay active for 10 minutes, then sleep...
      # sleep-idle-seconds = "600";
      slot-save-path = "/var/cache/llama-cpp/slots";
      models-preset = toString (pkgs.writeText "model-presets.ini" (lib.generators.toINI {} { 
        "Qwen3.5-2B" = {
          hf = "Jackrong/Qwen3.5-2B-Claude-4.6-Opus-Reasoning-Distilled-GGUF:Q6_K";
          alias = "hass-default,frigate-default";
          parallel = "1";
          /*temp = "0.7";
          top-p = "0.8";
          top-k = "20";
          min-p = "0.0";
          presence-penalty = "1.5";
          repeat-penalty = "1.0";*/
          reasoning = "on";
          reasoning-budget = "128";
          reasoning-budget-message = "... Reasoning budget exhausted. I should have enough to answer now.";
          /*t = "18";
          tb = "18";
          b = "2048";
          ub = "1024";*/
          /*ctk = "q4_0";
          ctv = "q4_0";*/
          flash-attn = "on";
          fit = "on";
          jinja = "on";
          mmproj-auto = "on";
          no-mmproj-offload = "on";
          spec-default = "on";
          context-shift = "on";
        };
      }));
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
  ];

  networking.firewall.interfaces.podman0.allowedTCPPorts = [
    ports.llama-cpp
  ];

}