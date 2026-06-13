{ config, self, pkgs, ports, lib, ... }:
{


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

}