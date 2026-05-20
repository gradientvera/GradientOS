{ self, config, lib, ... }:
let
  cfg = config.gradient.containers;
  ociCfg = config.virtualisation.oci-containers.containers;
in
{

  options.gradient.containers.autoUpdate = lib.mkEnableOption "Whether to set up the needed labels for the Podman auto-update support.";

  options.virtualisation.oci-containers.containers = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule ({ name, config, ... }:
    let
      # Containers that are attached to this one through --network=container:<name>
      childrenContainers = (lib.filterAttrs (n: v: n != name && (builtins.any (x: x == "container:${name}") v.networks)) ociCfg);
      # Which containers we're attached to --network=container:<name>
      parentContainers = (builtins.map (n: lib.strings.removePrefix "container:" n) (builtins.filter (n: lib.strings.hasPrefix "container:" n) config.networks));
      firstParent = if parentContainers == [] then null else builtins.head parentContainers;
    in
    {
      options.parentPorts = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Ports to be added to the first specified parent container's published ports.";
      };

      config = {
        extraOptions = lib.mkMerge [
          # Add network alias for all containers that depend on this one, for DNS purposes
          (lib.mapAttrsToList (n: _: "--network-alias=${n}") childrenContainers)
        ];
        labels = lib.mkIf cfg.autoUpdate (lib.mkDefault {
          "io.containers.autoupdate" = "registry";
          "PODMAN_SYSTEMD_UNIT" = "${config.serviceName}.service";
        });
        # Depend on specified containers for attaching to their networks.
        dependsOn = parentContainers;

        ports = lib.mkMerge [
          # If we have a parent, we shouldn't define any published ports... Use parentPorts instead.
          (lib.mkIf (firstParent != null) (lib.mkForce []))
          # If we don't have a parent, add the parent ports here in case I fucked up the config oops
          (lib.mkIf (firstParent == null) (config.parentPorts))
          # Copy ports from all attached children containers
          # probably only works for simple cases, "containers B and C attached to A" and not "container B attached to C attached to A"
          (lib.concatLists (lib.mapAttrsToList (_: v: v.parentPorts) childrenContainers))
        ];
      };
    }));
  };

}