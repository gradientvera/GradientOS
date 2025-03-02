{ config, ... }:

{

  sops = {
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    defaultSopsFile = ./secrets.yml;

    secrets = {

      wireguard-private-key = { restartUnits = [ "wireguard-*" ]; };

      nix-private-key = { };

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

      moonraker = {
        owner = config.services.moonraker.user;
        group = config.services.moonraker.group;
        path = "${config.services.moonraker.stateDir}/moonraker.secrets";
        restartUnits = [ "moonraker.service" ];
      };
    
    };
  };

}