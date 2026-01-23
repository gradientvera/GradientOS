{ config, pkgs, ... }:
let
  ports = config.gradient.currentHost.ports;
in
{

  services.headscale = {
    enable = true;
    address = "127.0.0.1";
    port = ports.headscale;

    settings.oidc = {
      pkce.enabled = true;
      client_id = "headscale";
      issuer = "https://identity.gradient.moe/oauth2/openid/headscale";
      scope = [
        "openid"
        "email"
        "profile"
        "groups"
      ];
      allowed_groups = [
        "constellation@identity.gradient.moe"
      ];
      extra_params = {
        domain_hint = "identity.gradient.moe";
      };
    };

    settings = {
      server_url = "https://headscale.constellation.moe";
      database.type = "sqlite";
      dns.base_domain = "tailnet.constellation.moe";
      dns.nameservers.global = [
        "1.1.1.1"
        "1.0.0.1"
        "8.8.8.8"
        "8.8.4.4"
      ];
    };
  };

}