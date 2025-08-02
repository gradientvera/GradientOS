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
      ];
    };
  };

  networking.firewall.interfaces.gradientnet.allowedTCPPorts = [
    ports.victoriametrics
  ];

}