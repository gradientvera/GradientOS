{ config, ... }:

{

  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    defaultSopsFile = ./secrets.yml;

    secrets = {
      "ssh-vera/private-key" = { path = "${config.home.homeDirectory}/.ssh/id_ed25519"; };
      "ssh-vera/authorized-keys" = { path = "${config.home.homeDirectory}/.ssh/authorized_keys"; };
    };

  };

}