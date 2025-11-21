{ self, config, lib, ... }:
let
  cfg = config.gradient.nginx;
  robotsTxt = "${self.inputs.ai-robots-txt}/robots.txt";
  nginxBlockAIBots = builtins.readFile "${self.inputs.ai-robots-txt}/nginx-block-ai-bots.conf";
in
{

  options.gradient.nginx.enableQuic = lib.mkEnableOption "Whether to enable QUIC support in all vhosts.";
  options.gradient.nginx.enablekTLS = lib.mkEnableOption "Whether to enable kTLS support in all vhosts.";
  options.gradient.nginx.enableBlockAIBots = lib.mkEnableOption "Whether to block AI scraper blocks.";

  options.services.nginx.virtualHosts = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule {
      config = {
        quic = lib.mkIf cfg.enableQuic true;
        http3_hq = lib.mkIf cfg.enableQuic true;
        kTLS = lib.mkIf cfg.enablekTLS true;
        extraConfig = lib.mkMerge [
          (lib.mkIf cfg.enableBlockAIBots nginxBlockAIBots)
          (lib.mkIf cfg.enableQuic ''
            quic_retry on;
            add_header alt-svc 'h3=":443"; ma=2592000,h3-29=":443"; ma=2592000';
          '')
        ];
        locations."= /robots.txt" = lib.mkIf cfg.enableBlockAIBots (lib.mkDefault {
          alias = robotsTxt;
        });
      };
    });
  };

}