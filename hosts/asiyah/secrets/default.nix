{ config, ... }:

{

  sops = {
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    defaultSopsFile = ./secrets.yml;

    secrets = {

      gradient-generator-environment = { restartUnits = [ "gradient-generator.daily-avatar.service" ]; };

      wireguard-private-key = { restartUnits = [ "wireguard-*" ]; };

      nix-private-key = { };
      
      oauth2-proxy-secrets = { restartUnits = [ "oauth2-proxy.service" ]; };

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

      mediarr-gluetun-uk-env = {
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
      
      cfdyndns-token = {
        restartUnits = [ "ddclient.service" ];
      };

      acme-cf-token = {
        restartUnits = [ "acme-gradient.moe.service" "acme-constellation.moe.service" ];
      };

      fail2ban-cf-token = {
        restartUnits = [ "fail2ban.service" ];
      };

      fail2ban-apprise-conf = {
        restartUnits = [ "fail2ban.service" ];
        path = "/etc/fail2ban/apprise.conf";
      };

      vaultwarden-env = {
        restartUnits = [ "vaultwarden.service" ];
      };

      kanidm-provisioning = {
        mode = "0550";
        format = "binary";
        sopsFile = ./kanidm-provisioning.encjson;
        owner = config.users.users.kanidm.name;
        group = config.users.users.kanidm.group;
        restartUnits = [ "kanidm.service" ];
      };

      kanidm-admin-password = {
        restartUnits = [ "kanidm.service" ];
        owner = config.users.users.kanidm.name;
        group = config.users.users.kanidm.group;
      };

      kanidm-idm-admin-password = {
        restartUnits = [ "kanidm.service" ];
        owner = config.users.users.kanidm.name;
        group = config.users.users.kanidm.group;
      };

      forgejo-ssh-priv = {
        restartUnits = [ "forgejo.service" ];
        owner = config.services.forgejo.user;
        group = config.services.forgejo.group;
      };

      forgejo-runner-token = {
        restartUnits = [ "forgejo.service" "gitea-runner-asiyah.service" ];
        owner = config.services.forgejo.user;
        group = config.services.forgejo.group;
      };

      paperless-env = {
        restartUnits = [ "paperless.service" ];
        owner = config.services.paperless.user;
      };

      paperless-admin-password = {
        restartUnits = [ "paperless.service" ];
        owner = config.services.paperless.user;
      };

      esphome-secrets = {
        owner = config.users.users.esphome.name;
        group = config.users.users.esphome.group;
        path = "${config.users.users.esphome.home}/secrets.yaml";
        restartUnits = [ "esphome.service" ];
      };

      nextcloud-admin-password = {
        owner = "nextcloud";
      };

      hass-secrets = {
        owner = config.users.users.hass.name;
        group = config.users.users.hass.group;
        path = "${config.users.users.hass.home}/secrets.yaml";
        restartUnits = [ "home-assistant.service" ];
      };

      hass-ssh-priv = {
        owner = config.users.users.hass.name;
        group = config.users.users.hass.group;
        restartUnits = [ "home-assistant.service" ];
      };

      pinchflat = {
        owner = config.services.pinchflat.user;
        group = config.services.pinchflat.group;
        restartUnits = [ "pinchflat.service" ];
      };

      constellation-homepage = {
        restartUnits = [ "homepage-dashboard.service" ];
      };

    };
  };

}