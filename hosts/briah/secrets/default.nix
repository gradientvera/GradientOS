{ config, ... }:

{

  sops = {
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    defaultSopsFile = ./secrets.yml;

    secrets = {
      
      wireguard-private-key = { restartUnits = [ "wireguard-*" ]; };

      nix-private-key = { };

      hostapd-password = {
        mode = "0444";
        restartUnits = [ "hostapd.service" ];
      };

      #pong-api-token = {
      #  mode = "0440";
      #  owner = config.users.users.ss14-watchdog.name;
      #  group = config.users.users.ss14-watchdog.group;
      #  restartUnits = [ "space-station-14-watchdog" ];
      #};

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

    };
  };

}