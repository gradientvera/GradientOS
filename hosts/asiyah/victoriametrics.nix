{ config, ports, ... }:
let
  addresses = config.gradient.const.wireguard.addresses.gradientnet;
  hosts = config.gradient.hosts;
in
{

  services.victoriametrics = {
    enable = true;
    listenAddress = ":${toString ports.victoriametrics}";
    prometheusConfig = {
        scrape_configs = [
        {
          job_name = "asiyah";
          static_configs = [
            {
              targets = [ "127.0.0.1:${toString ports.prometheus-node-exporter}" ];
              labels.type = "node";
            }
          ];
        }
        {
          job_name = "yetzirah";
          static_configs = [
            {
              targets = [ "${addresses.yetzirah}:${toString hosts.yetzirah.ports.prometheus-node-exporter}" ];
              labels.type = "node";
            }
          ];
        }
        {
          job_name = "bernkastel";
          static_configs = [
            {
              targets = [ "${addresses.bernkastel}:${toString hosts.bernkastel.ports.prometheus-node-exporter}" ];
              labels.type = "node";
            }
          ];
        }
      ];
    };
  };

}