{ lib, self, ... }:
let
  mkConstant = description: file:
    mkConstantBase description file (lib.types.attrsOf lib.types.str);
  mkConstantNested = description: file: 
    mkConstantBase description file (lib.types.attrsOf (lib.types.attrsOf lib.types.str));
  mkConstantFiles = description: file:
    mkConstantBase description file (lib.types.attrsOf lib.types.pathInStore);
  mkConstantBase = description: file: type: lib.mkOption {
    inherit type;
    default = import file;
    readOnly = true;
    description = mkDescription description;
  };
  mkDescription = description: 
    "${description}. Do not change this option's value, instead change the corresponding file.";
in
{

  options = {
    gradient.const.colmena.tags = mkConstant "Colmena tags"
      ./../misc/colmena-tags.nix;

    gradient.const.nix.pubKeys = mkConstant "Nix public keys" 
      ./../misc/nix-pub-keys.nix;

    gradient.const.ssh.pubKeys = mkConstant "SSH public keys"
      ./../misc/ssh-pub-keys.nix;

    gradient.const.syncthing.deviceIds = mkConstant "Syncthing device identifiers" 
      ./../misc/syncthing-device-ids.nix;

    gradient.const.wireguard.addresses = mkConstantNested "Wireguard VPN addresses"
      ./../misc/wireguard-addresses.nix;

    gradient.const.wireguard.pubKeys = mkConstant "Wireguard public keys"
      ./../misc/wireguard-pub-keys.nix;

    gradient.modules = mkConstantFiles "GradientOS Modules"
      ./../nixosModules.nix;

    gradient.mixins = mkConstantFiles "GradientOS Mixin Modules"
      ./../nixosMixins.nix;

    gradient.lib = lib.mkOption {
      type = lib.types.anything;
      default = (import ./../lib/default.nix) self;
    };
  };

}