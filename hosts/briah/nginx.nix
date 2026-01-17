 { config, lib, ... }:
 let
    ports = config.gradient.currentHost.ports;
    gradientnet = config.gradient.const.wireguard.addresses.gradientnet;
    asiyahPorts = config.gradient.hosts.asiyah.ports;
in
 {

  networking.firewall.allowedTCPPorts = [ ports.http ports.https asiyahPorts.lilynet ];
  networking.firewall.allowedUDPPorts = [ ports.http ports.https asiyahPorts.lilynet ];

  services.nginx = {
    enable = true;
    config = ''
      worker_processes auto;

      error_log /var/log/nginx/error.log crit;

      events {}
      
      stream {
        server {
          listen ${toString ports.http} reuseport;
          # listen ${toString ports.http} udp reuseport;
          listen [::]:${toString ports.http} reuseport;
          # listen [::]:${toString ports.http} udp reuseport;
          proxy_pass ${gradientnet.asiyah}:${toString asiyahPorts.nginx-proxy};
          proxy_protocol on;
        }

        server {
          listen ${toString ports.https} reuseport;
          # listen ${toString ports.https} udp reuseport;
          listen [::]:${toString ports.https} reuseport;
          # listen [::]:${toString ports.https} udp reuseport;
          proxy_pass ${gradientnet.asiyah}:${toString asiyahPorts.nginx-ssl-proxy};
          proxy_protocol on;
        }

        server {
          listen ${toString asiyahPorts.lilynet} reuseport;
          listen ${toString asiyahPorts.lilynet} udp reuseport;
          listen [::]:${toString asiyahPorts.lilynet} reuseport;
          listen [::]:${toString asiyahPorts.lilynet} udp reuseport;
          proxy_pass ${gradientnet.asiyah}:${toString asiyahPorts.lilynet};
        }
      }
    '';
  };

 }