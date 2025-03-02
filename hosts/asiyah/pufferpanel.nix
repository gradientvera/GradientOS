{ pkgs, lib, ... }:
let
  ports = import ./misc/service-ports.nix;
in
{

  services.pufferpanel = {
    enable = true;
    extraGroups = [
      "podman"
    ];
    environment = {
      PUFFER_WEB_HOST = ":${toString ports.pufferpanel}";
      PUFFER_DAEMON_SFTP_HOST = ":${toString ports.pufferpanel-sftp}";
      PUFFER_PANEL_ENABLE = "true";
      PUFFER_PANEL_REGISTRATIONENABLED = "false";
      PUFFER_PANEL_DATABASE_DIALECT = "postgresql";
      PUFFER_PANEL_DATABASE_URL = "host=localhost user=pufferpanel dbname=pufferpanel port=${toString ports.postgresql} sslmode=disable";
    };
    extraPackages = with pkgs; [ bash curl gawk gnutar gzip unzip ];
    package = pkgs.buildFHSEnv {
      name = "pufferpanel-fhs";
      runScript = lib.getExe pkgs.pufferpanel;
      targetPkgs = pkgs': with pkgs'; [ icu openssl zlib ];
    };
  };

  networking.firewall.interfaces.gradientnet.allowedTCPPorts = [
    ports.pufferpanel
    ports.pufferpanel-sftp
  ];

}