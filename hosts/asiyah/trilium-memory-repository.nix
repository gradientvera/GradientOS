{ config, pkgs, ... }:
let
  ports = import misc/service-ports.nix;
in {

  # Yes, I'm aware there's a NixOS module for this
  # No, I do not trust it
  virtualisation.oci-containers.containers.memory-repository = {
    image = "ghcr.io/triliumnext/notes:latest";
    pull = "newer";
    ports = [ "127.0.0.1:${toString ports.trilium}:8080" ];
    volumes = [ "/data/trilium:/home/node/trilium-data" ];
    environment = { TZ = config.time.timeZone; };
    extraOptions = [
      "--ip" "10.88.0.4"
    ];
  };

}