{ config, pkgs, ... }:
let
  script = config.sops.secrets.duckdns.path;
in {
  systemd.timers.duckdns = {
    description = "Updates dynamic DNS every 10 minutes";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      Unit = "duckdns.service";
      OnCalendar = "*-*-* *:0/10:00";
      Persistent = true;
    };
  };

  systemd.services.duckdns = {
    description = "Updates dynamic DNS.";
    after = [ "network-online.target" ];
    wants = [ "duckdns.timer" "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = script;
      User = config.users.users.duckdns.name;
      Environment="PATH=${pkgs.curl}/bin/";
    };
  };

  users.users.duckdns = {
    description = "User for dynamic DNS renewal.";
    isSystemUser = true;
    group = "duckdns";
  };
  users.groups.duckdns = {};
}