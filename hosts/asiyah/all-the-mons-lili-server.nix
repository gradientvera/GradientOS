{
  config,
  pkgs,
  ports,
  ...
}:
let
  jre = pkgs.javaPackages.compiler.temurin-bin.jre-21;
  port = ports.minecraft-all-the-mons-lili;
in
{
  users.groups.all-the-mons-lili-server = { };
  users.users.all-the-mons-lili-server = {
    isSystemUser = true;
    home = "/var/lib/all-the-mons-lili-server";
    createHome = true;
    homeMode = "750";
    group = config.users.groups.all-the-mons-lili-server.name;
  };

  # To send console commands: `echo "say hi" > /run/all-the-mons-lili-server.stdin`
  systemd.sockets.all-the-mons-lili-server = {
    partOf = [ "all-the-mons-lili-server.service" ];
    socketConfig = {
      ListenFIFO = "%t/all-the-mons-lili-server.stdin";
      SocketMode = "0666";
    };
  };

  systemd.services.all-the-mons-lili-server = {
    description = "All The Mons Lili Minecraft server";
    # Start manually: systemctl start all-the-mons-lili-server
    wantedBy = [ ];

    wants = [ "all-the-mons-lili-server.socket" ];
    after = [ "all-the-mons-lili-server.socket" ];

    path = [
      pkgs.bash
      pkgs.gawk
      jre
    ];
    serviceConfig = {
      User = config.users.users.all-the-mons-lili-server.name;
      Group = config.users.groups.all-the-mons-lili-server.name;
      WorkingDirectory = "~";
      Sockets = "all-the-mons-lili-server.socket";
      StandardInput = "socket";
      StandardOutput = "journal";
      StandardError = "journal";
      Nice = "-5";
      PrivateTmp = true;
      Restart = "on-failure";
    };
    script = ''
      if [ -f "$HOME/startserver.sh" ]; then
        exec bash "$HOME/startserver.sh"
      else
        echo "No startserver.sh in $HOME — copy the server files in first."
        exit 1
      fi
    '';
  };

  networking.firewall.allowedTCPPorts = [ port ];
  networking.firewall.allowedUDPPorts = [ port ];
}
