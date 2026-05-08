{ config, pkgs, lib, ... }:
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

  systemd.services.headscale.path = with pkgs; [
    sqlite
  ];

  systemd.services.tailscaled.after = [ "headscale.service" ];

  systemd.services.headscale.postStart = ''
      DB_PATH="${config.services.headscale.settings.database.sqlite.path}"

      sleep 5
      
      until [ -f $DB_PATH ]; do
        sleep 5
      done

      until sqlite3 $DB_PATH .tables | grep -q users; do
        sleep 5
      done

      until sqlite3 $DB_PATH .tables | grep -q pre_auth_keys; do
        sleep 5
      done

      sqlite3 $DB_PATH "insert or replace into users (id, name, display_name, email, created_at, updated_at, provider, provider_identifier) values (1, 'vera@identity.gradient.moe', 'Vera', 'gradientvera@outlook.com', datetime('now'), datetime('now'), 'oidc', 'https://identity.gradient.moe/oauth2/openid/headscale/ba86215f-acb9-49bc-a476-340e0b5f215d');"
      sqlite3 $DB_PATH "insert or replace into pre_auth_keys (id, user_id, reusable, expiration, created_at, tags, prefix, hash) values (1, 1, 1, datetime('now', '+999 years'), datetime('now'), '[]', '$(cat ${config.sops.secrets.tailscale-auth-prefix.path})', '$(cat ${config.sops.secrets.tailscale-auth-hash.path})');"
    '';

  # Keep restarting Headscale no matter what
  systemd.services.headscale.startLimitIntervalSec = lib.mkForce 0;
  systemd.services.headscale.startLimitBurst = lib.mkForce 0;
  systemd.services.headscale.serviceConfig.Restart = lib.mkForce "always";


}