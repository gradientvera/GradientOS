{ ports, ... }:
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
      ];
    };
  };

  networking.firewall.interfaces.gradientnet.allowedTCPPorts = [
    ports.victoriametrics
  ];

}