{ config, ... }:
let
  # Same path as moonraker.
  baseCfgPath = config.services.moonraker.stateDir;
  cfgPath = "${baseCfgPath}/config";
in
{

  services.klipper = {
    enable = true;
    user = config.services.moonraker.user;
    group = config.services.moonraker.group;
    mutableConfig = true;
    mutableConfigFolder = cfgPath;
    configFile = ./klipper.cfg;
    logFile = "${baseCfgPath}/logs/klipper.log";
  };

  # Do checks on config files, helps remind me to update them on git
  systemd.tmpfiles.settings."10-klipper"."${cfgPath}/printer.cfg".C = {
    argument = toString ./klipper.cfg;
    repoPath = "/etc/nixos/hosts/beatrice/klipper.cfg";
    doCheck = true;
    user = config.services.moonraker.user;
    group = config.services.moonraker.group;
    mode = "0777";
  };

}