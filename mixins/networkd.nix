{ lib, ... }:
{

  systemd.network.enable = true;

  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = true;
    settings = {
      server = [
        "1.1.1.1"
        "1.0.0.1"
        "8.8.8.8"
        "8.8.4.4"
      ];
    };
  };

}