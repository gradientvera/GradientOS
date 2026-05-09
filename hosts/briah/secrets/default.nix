{ config, ... }:

{

  sops = {
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    defaultSopsFile = ./secrets.yml;

    secrets = {

      wireguard-private-key = { restartUnits = [ "wireguard-*" ]; };

      # Headscale database provisioning
      headscale = {
        format = "binary";
        sopsFile = ./headscale.encsql;
        owner = config.services.headscale.user;
        group = config.services.headscale.group;
        restartUnits = [ "headscale.service" ];
      };

      headscale-noise-key = {
        owner = config.services.headscale.user;
        group = config.services.headscale.group;
        restartUnits = [ "headscale.service" ];
      };

    };
  };

}