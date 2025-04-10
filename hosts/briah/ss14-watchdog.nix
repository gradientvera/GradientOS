{ config, ... }:
let
  ports = config.gradient.currentHost.ports;
  pong-api-token = config.sops.secrets.pong-api-token.path;
in {

  services.space-station-14-watchdog = {
    enable = true;
    openApiFirewall = true;
    settings.Servers.Instances.Pong = {
      Name = "Robust Pong";
      ApiPort = ports.robust-pong;
      ApiTokenFile = pong-api-token;
      TimeoutSeconds = 120;
      UpdateType = "Git";
      Updates = {
        BaseUrl = "https://github.com/space-wizards/RobustToolbox-Examples-Pong.git";
        Branch = "master";
      };
    };
    instances.Pong.configuration = let
      port = toString ports.robust-pong;
    in {
      net = {
        tickrate = 60;
        port = ports.robust-pong;
      };

      hub = {
        advertise = true;
        server_url = "ss14://ss14.gradient.moe:${port}";
        tags = "region:eu_w,rp:none";
      };

      status = {
        enabled = true;
        connectaddress = "udp://ss14.gradient.moe:${port}";
        bind = "*:${port}";
      };

      auth = {
        mode = 1;
        allowlocal = false;
      };

      game = {
        hostname = "[EUW] Robust Pong";
        desc = "It's literally just pong.";
        welcomemsg = "Welcome to Robust Pong!";
      };
    };
  };

  networking.firewall.allowedTCPPorts = with ports; [ ss14-watchdog ];

}