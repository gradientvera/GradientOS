{ config, ... }:
let
  ports = import ./misc/service-ports.nix;
in
{

  services.searx = {
    enable = true;
    environmentFile = config.sops.secrets.searx.path;
    settings = {
      use_default_settings = true;
      server.port = ports.searx;
      server.bind_address = "0.0.0.0";
      server.secret_key = "@SEARX_SECRET_KEY@";
    };  
  };

  networking.firewall.interfaces.gradientnet.allowedTCPPorts = [ ports.searx ];
  networking.firewall.interfaces.gradientnet.allowedUDPPorts = [ ports.searx ];

}