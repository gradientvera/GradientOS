{ pkgs, ... }:
let
  ports = import ./misc/service-ports.nix;
in
{

  services.pufferpanel = {
    enable = true;
    extraPackages = [ 
      pkgs.gnutar
    ];
    environment = {
      PUFFER_WEB_HOST = ":${toString ports.pufferpanel}";
      PUFFER_DAEMON_SFTP_HOST = ":${toString ports.pufferpanel-sftp}";
      PUFFER_PANEL_ENABLE = "true";
      PUFFER_PANEL_REGISTRATIONENABLED = "false";
      PUFFER_PANEL_DATABASE_DIALECT = "postgresql";
      PUFFER_PANEL_DATABASE_URL = "host=localhost user=pufferpanel dbname=pufferpanel port=${toString ports.postgresql} sslmode=disable";
    };
  };

  networking.firewall.interfaces.gradientnet.allowedTCPPorts = [
    ports.pufferpanel
    ports.pufferpanel-sftp
  ];

}