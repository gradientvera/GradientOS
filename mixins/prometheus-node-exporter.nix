{ ports, ... }:
{

  services.prometheus.exporters.node = {
    enable = true;
    enabledCollectors = [ "systemd" "filesystem" "cpu" "netdev" "hwmon" "meminfo" "diskstats" "zfs" ];
    port = ports.prometheus-node-exporter;
  };

  networking.firewall.interfaces.gradientnet.allowedTCPPorts = [ ports.prometheus-node-exporter ];

}