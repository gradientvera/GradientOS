{ config, ... }:
let
  ports = import ./misc/service-ports.nix;
in
{

  services.ollama = {
    enable = true;
    port = ports.ollama;
    acceleration = false;
  };

  services.open-webui = {
    enable = true;
    port = ports.open-webui;
    environment = {
      OLLAMA_API_BASE_URL = "http://127.0.0.1:${toString ports.ollama}";
      WEBUI_AUTH = "False";

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