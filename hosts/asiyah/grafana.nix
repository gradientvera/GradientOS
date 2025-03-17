{ config, pkgs, ... }:
let
  ports = import ./misc/service-ports.nix;
in
{

  services.grafana = {
    enable = true;
    settings = {
      server = {
        domain = "grafana.asiyah.gradient.moe";
        root_url = "%(protocol)s://%(domain)s/";
        serve_from_sub_path = false;
        http_port = ports.grafana;
        http_addr = "127.0.0.1";
      };
    };
  };

  services.prometheus = {
    enable = true;
    port = ports.prometheus;
    exporters.node = {
      enable = true;
      enabledCollectors = [ "systemd" ];
      port = ports.prometheus-node-exporter;
    };
    scrapeConfigs = [
      {
        job_name = "asiyah";
        static_configs = [
          { targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ]; }
        ];
      }
    ];
  };

  services.loki = {
    enable = true;
    configFile = pkgs.writeText "loki-config.yaml" ''
auth_enabled: false

server:
  http_listen_port: ${toString ports.loki}

ingester:
  lifecycler:
    address: 0.0.0.0
    ring:
      kvstore:
        store: inmemory
      replication_factor: 1
    final_sleep: 0s
  chunk_idle_period: 1h       # Any chunk not receiving new logs in this time will be flushed
  max_chunk_age: 1h           # All chunks will be flushed when they hit this age, default is 1h
  chunk_target_size: 1048576  # Loki will attempt to build chunks up to 1.5MB, flushing first if chunk_idle_period or max_chunk_age is reached first
  chunk_retain_period: 30s    # Must be greater than index read cache TTL if using an index cache (Default index read cache TTL is 5m)

common:
  path_prefix: /var/lib/loki

schema_config:
  configs:
  - from: 2020-05-15
    store: tsdb
    object_store: filesystem
    schema: v13
    index:
      prefix: index_
      period: 24h

storage_config:
  filesystem:
    directory: /var/lib/loki/chunks

limits_config:
  reject_old_samples: true
  reject_old_samples_max_age: 168h

table_manager:
  retention_deletes_enabled: false
  retention_period: 0s
  '';
  };

  services.promtail = {
    enable = true;
    configuration = {
      server = {
        http_listen_port = ports.promtail;
        grpc_listen_port = 0;
      };

      positions.filename = "/tmp/positions.yaml";

      clients = [{url = "http://127.0.0.1:${toString ports.loki}/loki/api/v1/push";}];

      scrape_configs = [
        {
          job_name = "journal";
          journal = {
            max_age = "12h";
            labels = {
              job = "systemd-journal";
              host = "asiyah";
            };
          };
          relabel_configs = [
            {
              source_labels = [ "__journal__systemd_unit" ];
              target_label = "unit";
            }
          ];
        }
      ];
    };
  };

}