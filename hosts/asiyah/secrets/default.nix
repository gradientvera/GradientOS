{ config, ... }:

# When modifying this keep in mind that
# it is also going to be loaded by the
# rescue specialisation which does not
# have any of the usual services enabled.

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
        mode = "0440";
        restartUnits = [ "duckdns.service" ];
      };

      searx = {
        mode = "0440";
        owner = config.users.users.searx.name or null;
        group = config.users.users.searx.group or null;
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
        owner = config.users.users.mediarr.name or null;
        group = config.users.users.mediarr.group or null;
        restartUnits = [ "podman-gluetun.service" ];
      };

      mediarr-gluetun-uk-env = {
        mode = "0440";
        owner = config.users.users.mediarr.name or null;
        group = config.users.users.mediarr.group or null;
        restartUnits = [ "podman-gluetun.service" ];
      };

      mediarr-iptv-env = {
        mode = "0440";
        owner = config.users.users.mediarr.name or null;
        group = config.users.users.mediarr.group or null;
        restartUnits = [ "podman-ersatztv.service" ];
      };

      mediarr-unpackerr-env = {
        mode = "0440";
        owner = config.users.users.mediarr.name or null;
        group = config.users.users.mediarr.group or null;
        restartUnits = [ "podman-unpackerr.service" ];
      };

      mediarr-qbittorrent-script = {
        mode = "0550";
        owner = config.users.users.mediarr.name or null;
        group = config.users.users.mediarr.group or null;
        restartUnits = [ "podman-qbittorrent.service" ];
      };

      mediarr-decluttarr-env = {
        mode = "0440";
        owner = config.users.users.mediarr.name or null;
        group = config.users.users.mediarr.group or null;
        restartUnits = [ "podman-decluttarr.service" ];
      };

      mediarr-custom-axios = {
        mode = "0440";
        format = "binary";
        sopsFile = ./Axios.js;
        owner = config.users.users.mediarr.name or null;
        group = config.users.users.mediarr.group or null;
        restartUnits = [ "podman-tdarr.service" ];
      };

      mediarr-romm-env = {
        mode = "0440";
        owner = config.users.users.mediarr.name or null;
        group = config.users.users.mediarr.group or null;
        restartUnits = [ "podman-romm.service" ];
      };

      mediarr-mariadb-env = {
        mode = "0440";
        owner = config.users.users.mediarr.name or null;
        group = config.users.users.mediarr.group or null;
        restartUnits = [ "podman-mariadb.service" ];
      };

      mediarr-neko-env = {
        mode = "0440";
        owner = config.users.users.mediarr.name or null;
        group = config.users.users.mediarr.group or null;
        restartUnits = [ "podman-neko.service" ];
      };

      mediarr-amule-env = {
        mode = "0440";
        owner = config.users.users.mediarr.name or null;
        group = config.users.users.mediarr.group or null;
        restartUnits = [ "podman-amule.service" ];
      };
      
      mediarr-shelfmark-env = {
        mode = "0440";
        owner = config.users.users.mediarr.name or null;
        group = config.users.users.mediarr.group or null;
        restartUnits = [ "podman-shelfmark.service" ];
      };
      
      mediarr-calibre-env = {
        mode = "0440";
        owner = config.users.users.mediarr.name or null;
        group = config.users.users.mediarr.group or null;
        restartUnits = [ "podman-calibre.service" ];
      };
      
      cfdyndns-token = {
        restartUnits = [ "ddclient.service" ];
      };

      acme-cf-token = {
        restartUnits = [ "acme-gradient.moe.service" "acme-constellation.moe.service" ];
      };

      vaultwarden-env = {
        restartUnits = [ "vaultwarden.service" ];
      };

      kanidm-provisioning = {
        mode = "0550";
        format = "binary";
        sopsFile = ./kanidm-provisioning.encjson;
        owner = config.users.users.kanidm.name or null;
        group = config.users.users.kanidm.group or null;
        restartUnits = [ "kanidm.service" ];
      };

      kanidm-admin-password = {
        restartUnits = [ "kanidm.service" ];
        owner = config.users.users.kanidm.name or null;
        group = config.users.users.kanidm.group or null;
      };

      kanidm-idm-admin-password = {
        restartUnits = [ "kanidm.service" ];
        owner = config.users.users.kanidm.name or null;
        group = config.users.users.kanidm.group or null;
      };

      forgejo-ssh-priv = {
        restartUnits = [ "forgejo.service" ];
        owner = config.services.forgejo.user or null;
        group = config.services.forgejo.group or null;
      };

      forgejo-runner-token = {
        restartUnits = [ "forgejo.service" "gitea-runner-asiyah.service" ];
        owner = config.services.forgejo.user or null;
        group = config.services.forgejo.group or null;
      };

      paperless-env = {
        restartUnits = [ "paperless.service" ];
        owner = if config.services.paperless.enable then config.services.paperless.user else null;
      };

      paperless-admin-password = {
        restartUnits = [ "paperless.service" ];
        owner = if config.services.paperless.enable then config.services.paperless.user else null;
      };

      esphome-secrets = {
        mode = "0440";
        owner = "esphome";
        group = "esphome";
        path = "/var/lib/private/esphome/secrets.yaml";
        restartUnits = [ "esphome.service" ];
      };

      hass-secrets = {
        owner = config.users.users.hass.name or null;
        group = config.users.users.hass.group or null;
        path = "/var/lib/hass/secrets.yaml";
        restartUnits = [ "home-assistant.service" ];
      };

      hass-ssh-priv = {
        owner = config.users.users.hass.name or null;
        group = config.users.users.hass.group or null;
        restartUnits = [ "home-assistant.service" ];
      };

      pinchflat = {
        owner = config.users.users.mediarr.name or null;
        group = config.users.users.mediarr.group or null;
        restartUnits = [ "pinchflat.service" ];
      };

      constellation-homepage = {
        restartUnits = [ "homepage-dashboard.service" ];
      };

      atticd-environment = {
        restartUnits = [ "atticd.service" ];
      };

      calibre-opds-credentials = {
        restartUnits = [ "nginx.service" ];
        owner = if config.services.nginx.enable then config.services.nginx.user else null;
        group = if config.services.nginx.enable then config.services.nginx.group else null;
      };

      grafana-secret-key = {
        restartUnits = [ "grafana.service" ];
        owner = config.users.users.grafana.name or null;
        group = config.users.users.grafana.group or null;
      };

      the-things-network-mosquitto = {
        restartUnits = [ "mosquitto.service" ];
        owner = config.users.users.mosquitto.name or null;
        group = config.users.users.mosquitto.group or null;
        path = "/etc/mosquitto.d/the-things-network-bridge.conf";
      };

    };
  };

}