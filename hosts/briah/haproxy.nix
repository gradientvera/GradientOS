{ config, ... }:
let
    ports = config.gradient.currentHost.ports;
    gradientnet = config.gradient.const.wireguard.addresses.gradientnet;
    asiyahPorts = config.gradient.hosts.asiyah.ports;
in
{

  networking.firewall.allowedTCPPorts = [ ports.haproxy ports.haproxy-ssl ];

  services.haproxy = {
    enable = true;
    config = ''
      global
        daemon
        log 127.0.0.1 local0
        log 127.0.0.1 local1 notice
        maxconn 60000

      defaults
        log global
        retries 3

      frontend web
        mode tcp
        bind :${toString ports.haproxy}
        default_backend asiyahweb

      frontend websecure
        mode tcp
        bind :${toString ports.haproxy-ssl}
        default_backend asiyahwebsecure

      backend asiyahweb
        mode tcp
        balance roundrobin
        server asiyah ${gradientnet.asiyah}:${toString asiyahPorts.nginx-proxy} check send-proxy-v2

      backend asiyahwebsecure
        mode tcp
        balance roundrobin
        server asiyah ${gradientnet.asiyah}:${toString asiyahPorts.nginx-ssl-proxy} check send-proxy-v2
    '';
  };

}