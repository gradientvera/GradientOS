{ lib, self, config, ... }:
let
  gradientLib = (import ./../lib/default.nix) self;
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
  hostType = (lib.types.submodule {
    options.ports = lib.mkOption {
      type = lib.types.attrsOf lib.types.port;
      readOnly = true;  
      description = mkDescription "A collection of service ports for the host";
    };
  });
  mkHosts = lib.mkOption {
    type = lib.types.attrsOf hostType;
    readOnly = true;
    description = "Read-only attribute set of different constants for each host in the config.";
    default =
      let
        hostNames = lib.map (f: f.name) (builtins.filter (f: f.value == "directory") (lib.attrsToList (builtins.readDir ../hosts)));
        mkHost = name: {
          ports = gradientLib.mkPorts name;
        };
      in
      builtins.listToAttrs (lib.map (h: { name = h; value = mkHost h;} ) hostNames);
  };
  mkCurrentHost = lib.mkOption {
    type = hostType;
    readOnly = true;
    description = "Read-only attribute set of differnt constants for the current host in the config.";
    default = config.gradient.hosts.${config.networking.hostName};
  };
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

    gradient.const.localAddresses = mkConstant "Local MDNS addresses"
      ./../misc/local-addresses.nix;

    gradient.hosts = mkHosts;

    gradient.currentHost = mkCurrentHost;

    gradient.modules = mkConstantFiles "GradientOS Modules"
      ./../nixosModules.nix;

    gradient.mixins = mkConstantFiles "GradientOS Mixin Modules"
      ./../nixosMixins.nix;

    gradient.lib = lib.mkOption {
      type = lib.types.anything;
      readOnly = true;
      default = gradientLib;
    };
  };

}