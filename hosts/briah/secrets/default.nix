{ config, ... }:

{

  sops = {
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    defaultSopsFile = ./secrets.yml;

    secrets = {

      wireguard-private-key = { restartUnits = [ "wireguard-*" ]; };

      tailscale-auth-prefix = {
        owner = config.services.headscale.user;
        group = config.services.headscale.group;
        restartUnits = [ "headscale.service" ];
      };

      tailscale-auth-hash = {
        owner = config.services.headscale.user;
        group = config.services.headscale.group;
        restartUnits = [ "headscale.service" ];
      };

    };
  };

}