{ config, pkgs, lib, ... }:
let
  ports = config.gradient.currentHost.ports;
in
{

  services.ollama = {
    enable = true;
    package = pkgs.ollama-vulkan;
    port = ports.ollama;
    syncModels = true;
    loadModels = [
      config.services.frigate.settings.genai.model
    ];
    environmentVariables = {
      OLLAMA_VULKAN = "1";
    };
  };

  services.open-webui = {
    enable = true;
    port = ports.open-webui;
    environment = {
      OLLAMA_API_BASE_URL = "http://127.0.0.1:${toString ports.ollama}";
      WEBUI_AUTH = "False";

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
    wants = [ "redis-open-webui.service" "searx.service" "ollama.service" ];
    after = [ "redis-open-webui.service" "searx.service" "ollama.service" ];
  };

  networking.firewall.interfaces.gradientnet.allowedTCPPorts = [
    ports.ollama
  ];

}