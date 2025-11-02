{ pkgs, config, ... }:
let
  ports = config.gradient.currentHost.ports;
in
{

  services.postgresql = {
    enable = true;
    enableJIT = true;
    enableTCPIP = true;
    package = pkgs.postgresql_17_jit;
    settings.port = ports.postgresql;
    ensureDatabases = [
      "hass"
      "bitmagnet"
      "pufferpanel"
      "vaultwarden"
      "forgejo"
      "grafana"
      "trmnl"
      "atticd"
    ];
    ensureUsers = [
      {
        name = "hass";
        ensureDBOwnership = true;
      }
      {
        name = "bitmagnet";
        ensureDBOwnership = true;
      }
      {
        name = "pufferpanel";
        ensureDBOwnership = true;
      }
      {
        name = "vaultwarden";
        ensureDBOwnership = true;
      }
      {
        name = "forgejo";
        ensureDBOwnership = true;
      }
      {
        name = "grafana";
        ensureDBOwnership = true;
      }
      {
        name = "trmnl";
        ensureDBOwnership = true;
      }
      {
        name = "atticd";
        ensureDBOwnership = true;
      }
    ];
    authentication = ''
      # Local services
      local hass hass peer
      local vaultwarden vaultwarden peer
      local forgejo forgejo peer
      local atticd atticd peer
      host pufferpanel pufferpanel 127.0.0.1/32 trust
      host pufferpanel pufferpanel ::1/128 trust
      host grafana grafana 127.0.0.1/32 trust
      host atticd atticd 127.0.0.1/32 trust

      # Podman network
      host bitmagnet bitmagnet 10.88.0.0/24 trust
      host trmnl trmnl 10.88.0.0/24 trust
    '';
    # PGTune settings
    settings = {
      # DB Version: 17
      # OS Type: linux
      # DB Type: mixed
      # Total Memory (RAM): 128 GB
      # CPUs num: 36
      # Data Storage: ssd

      max_connections = 100;
      shared_buffers = "16GB";
      effective_cache_size = "48GB";
      maintenance_work_mem = "2GB";
      checkpoint_completion_target = 0.9;
      wal_buffers = "16MB";
      default_statistics_target = 100;
      random_page_cost = 1.1;
      effective_io_concurrency = 200;
      work_mem = "20971kB";
      huge_pages = "try";
      min_wal_size = "1GB";
      max_wal_size = "4GB";
      max_worker_processes = 36;
      max_parallel_workers_per_gather = 4;
      max_parallel_workers = 36;
      max_parallel_maintenance_workers = 4;
    };
  };

  networking.firewall.interfaces.podman0.allowedTCPPorts = with ports; [
    postgresql
  ];

}