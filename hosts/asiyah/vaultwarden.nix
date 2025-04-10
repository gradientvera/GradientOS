{ config, ... }:
let
  ports = config.gradient.currentHost.ports;
in
{

  services.vaultwarden = {
    enable = true;
    dbBackend = "postgresql";
    environmentFile = config.sops.secrets.vaultwarden-env.path;
    config = {
      DOMAIN = "https://bitwarden.asiyah.gradient.moe";
      SIGNUPS_ALLOWED = false;
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = ports.vaultwarden;
      DATABASE_URL = "postgresql://vaultwarden@/vaultwarden";
    };
  };

}