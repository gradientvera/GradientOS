{ pkgs, config, lib, ... }:
let
  ports = import ./misc/service-ports.nix;
  group = "media-stack";
in {

  services.jellyfin = {
    inherit group;
    enable = true;
  };

  systemd.services.jellyfin.serviceConfig = {
    DeviceAllow = lib.mkForce "char-drm";
    BindPaths = lib.mkForce "/dev/dri";
    Restart = lib.mkForce "always";
  };

  services.radarr = {
    inherit group;
    enable = true;
  };

  services.sonarr = {
    inherit group;
    enable = true;
    openFirewall = true;
  };
  
  services.prowlarr = {
    enable = true;
  };

  services.bazarr = {
    inherit group;
    enable = true;
    listenPort = ports.bazarr;
  };

  virtualisation.oci-containers.containers.flaresolverr = {
    image = "ghcr.io/flaresolverr/flaresolverr:latest";
    #ports = [ "${toString ports.flaresolverr}:8191" ];
    environment = { LOG_LEVEL="info"; };
    extraOptions = [ "--network=host" ];
  };

  services.deluge = {
    inherit group;
    enable = true;
    declarative = true;
    openFirewall = true;
    authFile = config.sops.secrets.deluge-auth.path;
    web = {
      enable = true;
      port = ports.deluge-web;
    };
    config = {
      daemon_port = ports.deluge-daemon;
      listen_ports = ports.deluge-listen;
      
      enabled_plugins = [ "Label" ];

      max_active_limit = -1;
      max_active_downloading = -1;
      max_active_seeding = 10;

      max_download_speed = 20000.0;
      max_upload_speed = 5000.0;

      remove_seed_at_ratio = true;
      stop_seed_ratio = 2.0;
      
      download_location = "/data/Downloads/Incomplete";
      
      move_completed = true;
      move_completed_path = "/data/Downloads/Complete";
      
      copy_torrent_file = true;
      torrentfiles_location = "/data/Downloads/Torrents";
    };
  };

  networking.firewall.interfaces.gradientnet.allowedTCPPorts = with ports; [
    jellyfin-http
    jellyfin-https
    radarr
    sonarr
    prowlarr
    bazarr
    flaresolverr
    deluge-web
  ];
  
  networking.firewall.interfaces.gradientnet.allowedUDPPorts = with ports; [
    jellyfin-client-discovery
  ];

  users.groups.${group}.members = with config.services; [
    jellyfin.user
    radarr.user
    sonarr.user
    bazarr.user
    deluge.user
  ];
}