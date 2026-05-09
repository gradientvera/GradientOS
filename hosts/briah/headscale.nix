{ config, pkgs, lib, ... }:
let
  addresses = config.gradient.const.addresses;
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
      policy = {
        mode = "file";
        path = pkgs.writeText "policy.json" (builtins.toJSON (import ../../misc/headscale-acl.nix));
      };
      prefixes.v4 = addresses.tailscale-ipv4;
      prefixes.v6 = addresses.tailscale-ipv6;
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

      sqlite3 $DB_PATH < ${config.sops.secrets.headscale.path}
    '';

  # Keep restarting Headscale no matter what
  systemd.services.headscale.startLimitIntervalSec = lib.mkForce 0;
  systemd.services.headscale.startLimitBurst = lib.mkForce 0;
  systemd.services.headscale.serviceConfig.Restart = lib.mkForce "always";


}