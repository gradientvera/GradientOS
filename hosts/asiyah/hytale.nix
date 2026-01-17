{ config, pkgs, ports, ... }:
{

  users.groups.hytale = {};
  users.users.hytale = {
    isSystemUser = true;
    home = "/var/lib/hytale";
    createHome = true;
    homeMode = "750";
    group = config.users.groups.hytale.name;
  };

  systemd.services.hytale-server = {
    description = "Hytale Server";
    wantedBy = [  ]; # needs manual startup
    path = [ pkgs.javaPackages.compiler.temurin-bin.jre-25 ];
    serviceConfig = {
      User = config.users.users.hytale.name;
      Group = config.users.groups.hytale.name;
      WorkingDirectory = "~";
    };
    script = ''
      if [ ! -f $HOME/HytaleServer.jar ]; then
        echo "Hytale server executable not found!"
        exit 1
      fi

      java -jar HytaleServer.jar --allow-op --backup --backup-dir $HOME/backups --assets $HOME/Assets.zip --bind 0.0.0.0:${toString ports.hytale}
    '';
  };

  networking.firewall.allowedTCPPorts = [ ports.hytale ];
  networking.firewall.allowedUDPPorts = [ ports.hytale ];

}