{ config, lib, ... }:
let
  cfg = config.gradient;
in
{
  options = {
    gradient.installer.addSsh = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether to enable root SSH access with my personal keys on a fresh install's config.
      '';
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.installer.addSsh {
      system.nixos-generate-config.desktopConfiguration = [
        "services.openssh.enable = true;"
        "services.openssh.openFirewall = true;"
        "users.users.root.openssh.authorizedKeys.keys = [ \"${cfg.const.ssh.pubKeys.vera}\" ];"
      ];
    })
  ];
}