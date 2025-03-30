{ self, config, lib, ... }:
let
  cfg = config.gradient.nginx;
  robotsTxt = "${self.inputs.ai-robots-txt}/robots.txt";
  nginxBlockAIBots = builtins.readFile "${self.inputs.ai-robots-txt}/nginx-block-ai-bots.conf";
in
{

  options.gradient.nginx.enableBlockAIBots = lib.mkEnableOption "Whether to block AI scraper blocks.";

  options.services.nginx.virtualHosts = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule {
      config = {
        extraConfig = nginxBlockAIBots;
        locations."= /robots.txt" = lib.mkIf cfg.enableBlockAIBots (lib.mkDefault {
          alias = robotsTxt;
        });
      };
    });
  };

}