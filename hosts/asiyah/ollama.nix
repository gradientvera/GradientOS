{ config, ... }:
let
  ports = config.gradient.currentHost.ports;
in
{

/*
  services.ollama = {
    enable = true;
    port = ports.ollama;
    acceleration = false;
  };
*/

  systemd.tmpfiles.settings."99-ollama-ipex.conf"."/var/lib/ollama-ipex".d = {
    mode = "0775";
  };

  virtualisation.oci-containers.containers.ollama-ipex = {
    image = "intelanalytics/ipex-llm-inference-cpp-xpu:latest";
    pull = "newer";
    volumes = [ "/var/lib/ollama-ipex:/root/.ollama" ];
    ports = [
      "127.0.0.1:${toString ports.ollama}:11434"
    ];
    environment = {
      TZ = config.time.timeZone;
      no_proxy = "localhost,127.0.0.1";
      OLLAMA_HOST = "0.0.0.0";
      DEVICE = "arc";
      OLLAMA_INTEL_GPU = "true";
      OLLAMA_NUM_GPU = "999";
      ZES_ENABLE_SYSMAN = "1";
    };
    devices = [
      "/dev/dri:/dev/dri"
    ];
    entrypoint = "/bin/sh";
    cmd = [ "-c" "'mkdir -p /llm/ollama && cd /llm/ollama && init-ollama && exec ./ollama serve'" ];
  };

  services.open-webui = {
    enable = true;
    port = ports.open-webui;
    environment = {
      OLLAMA_API_BASE_URL = "http://127.0.0.1:${toString ports.ollama}";
      WEBUI_AUTH = "False";
      ENABLE_OPENAI_API = "False";
      ENABLE_OLLAMA_API = "True";

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