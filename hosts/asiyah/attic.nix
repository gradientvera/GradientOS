{ config, ports, ... }:
let
  storagePath = "/data/nix";
  secrets = config.sops.secrets;
in
{

  systemd.tmpfiles.settings."10-attic.conf" = {
    ${storagePath}.d = {
      mode = "0777";
    };
  };

  services.atticd = {
    enable = true;
    environmentFile = secrets.atticd-environment.path;
    settings = {
      listen = "[::]:${toString ports.attic}";
      allowed-hosts = [ "cache.gradient.moe" ];
      api-endpoint = "https://cache.gradient.moe/";
      jwt = { };
      database = {
        url = "postgresql://atticd@127.0.0.1/atticd";
        heartbeat = true;
      };
      storage = {
        type = "local";
        path = storagePath;
      };
    };
  };

}