{ config, ports, ... }:
{

  services.alloy = {
    enable = true;
    extraFlags = [
      "--server.http.listen-addr=127.0.0.1:${toString ports.alloy}"
    ];
  };

  systemd.services.alloy.serviceConfig.SupplementaryGroups = [
    "auditd"
  ];

  environment.etc."alloy/config.alloy".text = ''
    loki.relabel "journal" {
      forward_to = []

      rule {
        source_labels = ["__journal__systemd_unit"]
        target_label  = "unit"
      }
    }

    loki.source.journal "read"  {
      forward_to    = [loki.write.endpoint.receiver]
      relabel_rules = loki.relabel.journal.rules
      labels        = {
        component = "loki.source.journal",
        job = "systemd-journal",
        host = "${config.networking.hostName}",
      }
    }
    
    loki.source.file "audit" {
      targets = [
        { __path__ = "/var/log/audit/audit.log", "type" = "auditd", "component" = "loki.source.file", "job" = "auditd", "unit" = "auditd.service", "host" = "${config.networking.hostName}" },
      ]
      forward_to = [loki.write.endpoint.receiver]
    }

    loki.write "endpoint" {
      endpoint {
        url = "http://${config.gradient.const.wireguard.addresses.gradientnet.asiyah}:${toString config.gradient.hosts.asiyah.ports.victorialogs}/insert/loki/api/v1/push"
      }
    }

    prometheus.exporter.unix "local_system" {
      include_exporter_metrics = true
      enable_collectors = [ "systemd", "filesystem", "cpu", "netdev", "hwmon", "meminfo", "diskstats", "zfs", "perf", "sysctl", "vmstat" ]
    }

    prometheus.scrape "scrape_metrics" {
      targets         = prometheus.exporter.unix.local_system.targets
      forward_to      = [prometheus.relabel.filter_metrics.receiver]
      scrape_interval = "10s"
    }

    prometheus.relabel "filter_metrics" {
      forward_to = [prometheus.remote_write.endpoint.receiver]
    }

    prometheus.remote_write "endpoint" {
      endpoint {
        url = "http://${config.gradient.const.wireguard.addresses.gradientnet.asiyah}:${toString config.gradient.hosts.asiyah.ports.victoriametrics}/api/v1/write"
      }
    }
  '';

  networking.firewall.interfaces.gradientnet.allowedTCPPorts = [
    ports.alloy
  ];

}