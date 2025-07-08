{ config, pkgs, ... }:
let
  ports = config.gradient.currentHost.ports;
in
{

  systemd.tmpfiles.settings."99-ollama-vulkan.conf"."/var/lib/ollama-vulkan".d = {
    mode = "0775";
  };

  virtualisation.oci-containers.containers.ollama-vulkan = {
    image = "ahmedsaed26/ollama-vulkan";
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

      SEARXNG_HOSTNAME = "http://127.0.0.1:${toString ports.searx}";
      ENABLE_RAG_WEB_SEARCH = "True";
      RAG_WEB_SEARCH_ENGINE = "searxng";
      RAG_WEB_SEARCH_RESULT_COUNT = "3";
      RAG_WEB_SEARCH_CONCURRENT_REQUESTS = "10";
      SEARXNG_QUERY_URL = "http://127.0.0.1:${toString ports.searx}/search?q=<query>";

      # what's the fucking point of hosting this shit locally otherwise??
      DO_NOT_TRACK = "True";
      SCARF_NO_ANALYTICS = "True";
      ANONYMIZED_TELEMETRY = "False";
    };
  };

  networking.firewall.interfaces.gradientnet.allowedTCPPorts = [
    ports.ollama
  ];

}