{ config, pkgs, lib, ... }:
let
  ports = config.gradient.currentHost.ports;
in
{

  systemd.tmpfiles.settings."99-large-lying-models.conf" = {
    "/var/lib/ollama-vulkan".d = {
      mode = "0775";
    };
  };

  virtualisation.oci-containers.containers.ollama-vulkan = {
    image = "ghcr.io/wilgnne/ollama-vulkan";
    pull = "newer";
    volumes = [ "/var/lib/ollama-vulkan:/root/.ollama" ];
    privileged = true;
    ports = [
      "127.0.0.1:${toString ports.ollama}:11434"
    ];
    environment = {
      TZ = config.time.timeZone;
      no_proxy = "localhost,127.0.0.1,10.88.0.1";
      OLLAMA_HOST = "0.0.0.0";
    };
    extraOptions = [
      "--device=/dev/dri:/dev/dri"
      "--shm-size=32g"
      "--memory=32g"
      "--cap-add=PERFMON"
    ];
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
    after = [ "redis-open-webui.service" "searx.service" ];
    wants = [ "redis-open-webui.service" "searx.service" ];
  };

  networking.firewall.interfaces.gradientnet.allowedTCPPorts = [
    ports.ollama
  ];

}