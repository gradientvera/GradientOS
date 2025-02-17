{ config, ... }:

{

  sops = {
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    defaultSopsFile = ./secrets.yml;

    secrets = {

      gradient-generator-environment = { restartUnits = [ "gradient-generator.daily-avatar.service" ]; };

      wireguard-private-key = { restartUnits = [ "wireguard-*" ]; };

      nix-private-key = { };
      
      oauth2-proxy-secrets = { restartUnits = [ "oauth2_proxy.service" ]; };

      duckdns = {
        mode = "0500";
        owner = config.users.users.duckdns.name;
        group = config.users.users.duckdns.group;
        restartUnits = [ "duckdns" ];
      };

      searx = {
        mode = "0440";
        owner = config.users.users.searx.name;
        group = config.users.users.searx.group;
        restartUnits = [ "searx.service" "searx-init.service" ];
      };

      syncthing-cert = {
        format = "binary";
        sopsFile = ./syncthing-cert.pem;
        restartUnits = [ "syncthing.service" ];
      };

      syncthing-key = {
        format = "binary";
        sopsFile = ./syncthing-key.pem;
        restartUnits = [ "syncthing.service" ];
      };

      mediarr-gluetun-env = {
        mode = "0440";
        owner = config.users.users.mediarr.name;
        group = config.users.users.mediarr.group;
        restartUnits = [ "podman-gluetun.service" ];
      };

      mediarr-iptv-env = {
        mode = "0440";
        owner = config.users.users.mediarr.name;
        group = config.users.users.mediarr.group;
        restartUnits = [ "podman-ersatztv.service" ];
      };

      mediarr-unpackerr-env = {
        mode = "0440";
        owner = config.users.users.mediarr.name;
        group = config.users.users.mediarr.group;
        restartUnits = [ "podman-unpackerr.service" ];
      };

      mediarr-qbittorrent-script = {
        mode = "0550";
        owner = config.users.users.mediarr.name;
        group = config.users.users.mediarr.group;
        restartUnits = [ "podman-qbittorrent.service" ];
      };

      mediarr-decluttarr-env = {
        mode = "0440";
        owner = config.users.users.mediarr.name;
        group = config.users.users.mediarr.group;
        restartUnits = [ "podman-decluttarr.service" ];
      };

      mediarr-custom-axios = {
        mode = "0440";
        format = "binary";
        sopsFile = ./Axios.js;
        owner = config.users.users.mediarr.name;
        group = config.users.users.mediarr.group;
        restartUnits = [ "podman-tdarr.service" ];
      };

      mediarr-romm-env = {
        mode = "0440";
        owner = config.users.users.mediarr.name;
        group = config.users.users.mediarr.group;
        restartUnits = [ "podman-romm.service" ];
      };

      mediarr-mariadb-env = {
        mode = "0440";
        owner = config.users.users.mediarr.name;
        group = config.users.users.mediarr.group;
        restartUnits = [ "podman-mariadb.service" ];
      };

      mediarr-neko-env = {
        mode = "0440";
        owner = config.users.users.mediarr.name;
        group = config.users.users.mediarr.group;
        restartUnits = [ "podman-neko.service" ];
      };
      
      cfdyndns-token = {};

    };
  };

}