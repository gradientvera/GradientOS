{ config, lib, self, ... }:
let
  cfg = config.gradient;
in
{
  imports = [
    self.inputs.sops-nix.nixosModules.sops
  ];

  options = {
    gradient.core.secrets.enable = lib.mkOption {
      type = lib.types.bool;
      default = cfg.core.enable;
      description = ''
        Whether to enable the core GradientOS secrets.
      '';
    };
  };

  config = lib.mkIf cfg.core.secrets.enable ({
    sops.secrets = {
      hokma-password = {
         sopsFile = ./secrets.yml;
      };
      hokma-environment = {
        sopsFile = ./secrets.yml;
      };
      upsmon-password = {
        sopsFile = ./secrets.yml;
      };
      rathole-credentials-server = {
        sopsFile = ./secrets.yml;
        restartUnits = [ "rathole.service" ];
      };
      rathole-credentials-client = {
        sopsFile = ./secrets.yml;
        restartUnits = [ "rathole.service" ];
      };
      wgautomesh-gossip-secret = {
        sopsFile = ./secrets.yml;
        restartUnits = [ "wgautomesh.service" ];
      };
      crowdsec-env = lib.mkIf config.services.crowdsec.enable {
        sopsFile = ./secrets.yml;
        owner = "crowdsec";
        group = "crowdsec";
        restartUnits = [ "crowdsec.service" "crowdsec-firewall-bouncer.service" ];
      };
      crowdsec-console-token = lib.mkIf config.services.crowdsec.enable {
        sopsFile = ./secrets.yml;
        owner = "crowdsec";
        group = "crowdsec";
        restartUnits = [ "crowdsec.service" ];
      };
    };
  });

}