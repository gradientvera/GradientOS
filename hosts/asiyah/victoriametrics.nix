{ config, ports, ... }:
let
  gradientnet = config.gradient.const.wireguard.addresses.gradientnet;
  hosts = config.gradient.hosts;
in
{

  services.victoriametrics = {
    enable = true;
    listenAddress = ":${toString ports.victoriametrics}";
    prometheusConfig = {
      scrape_configs = [
        {
          job_name = "VictoriaLogs";
          static_configs = [
            {
              targets = [ "http://127.0.0.1:${toString ports.victorialogs}/metrics" ];
            }
          ];
        }
        {
          job_name = "uptime";
          scrape_interval = "30s";
          scheme = "http";
          metrics_path = "/metrics";
          static_configs = [
            {
              targets = [ "127.0.0.1:${toString ports.uptime-kuma}" ];
            }
          ];
        }
        {
          job_name = "crowdsec";
          scrape_interval = "30s";
          scheme = "http";
          metrics_path = "/metrics";
          static_configs = [
            {
              targets = [
                "${gradientnet.asiyah}:${toString hosts.asiyah.ports.crowdsec-metrics}"
                "${gradientnet.briah}:${toString hosts.briah.ports.crowdsec-metrics}"
              ];
            }
          ];
        }
      ];
    };
  };

  networking.firewall.interfaces.gradientnet.allowedTCPPorts = [
    ports.victoriametrics
  ];

}