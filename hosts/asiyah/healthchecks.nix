{ config, ports, ... }:
let
  secrets = config.sops.secrets;
in
{

  services.healthchecks = {
    enable = true;
    port = ports.healthchecks;
    settings = {
      DEBUG = false;
      DB = "sqlite";
    };
  };

}