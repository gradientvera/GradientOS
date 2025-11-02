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
        log /dev/log local0 info
        maxconn 60000

      defaults
        log global
        retries 3
        timeout connect 10s
        timeout client 30s
        timeout server 30s

      frontend web
        mode tcp
        bind *:${toString ports.haproxy} v4v6
        bind :::${toString ports.haproxy} v6only
        default_backend asiyahweb

      frontend websecure
        mode tcp
        bind *:${toString ports.haproxy-ssl} v4v6
        bind :::${toString ports.haproxy-ssl} v6only
        default_backend asiyahwebsecure

      backend asiyahweb
        mode tcp
        server asiyah ${gradientnet.asiyah}:${toString asiyahPorts.nginx-proxy} check send-proxy-v2

      backend asiyahwebsecure
        mode tcp
        server asiyah ${gradientnet.asiyah}:${toString asiyahPorts.nginx-ssl-proxy} check send-proxy-v2
    '';
  };

}