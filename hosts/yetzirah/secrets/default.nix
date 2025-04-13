{ config, ... }:
{

  sops = {
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    defaultSopsFile = ./secrets.yml;

    secrets = {

      wireguard-private-key = { restartUnits = [ "wireguard-*" ]; };

      /*moonraker = {
        owner = config.services.moonraker.user;
        group = config.services.moonraker.group;
        path = "${config.services.moonraker.stateDir}/moonraker.secrets";
        restartUnits = [ "moonraker.service" ];
      };*/

      network-manager-env = {
        restartUnits = [ "NetworkManager.service" ];
      };

    };
  };


}