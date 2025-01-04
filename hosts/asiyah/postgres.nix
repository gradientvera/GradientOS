{ pkgs, config, ... }:
let
  ports = import ./misc/service-ports.nix;
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
    ];
    authentication = ''
      # Home Assistant
      local hass hass peer
      
      # Podman network
      host bitmagnet bitmagnet 10.88.0.0/24 trust
    '';
    # PGTune settings
    settings = {
      # DB Version: 17
      # OS Type: linux
      # DB Type: mixed
      # Total Memory (RAM): 32 GB
      # CPUs num: 8
      # Data Storage: ssd

      max_connections = 100;
      shared_buffers = "8GB";
      effective_cache_size = "24GB";
      maintenance_work_mem = "2GB";
      checkpoint_completion_target = 0.9;
      wal_buffers = "16MB";
      default_statistics_target = 100;
      random_page_cost = 1.1;
      effective_io_concurrency = 200;
      work_mem = "10485kB";
      huge_pages = "try";
      min_wal_size = "1GB";
      max_wal_size = "4GB";
      max_worker_processes = 8;
      max_parallel_workers_per_gather = 4;
      max_parallel_workers = 8;
      max_parallel_maintenance_workers = 4;
    };
  };

  networking.firewall.interfaces.podman0.allowedTCPPorts = with ports; [
    postgresql
  ];

}