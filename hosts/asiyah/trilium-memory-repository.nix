{ config, ... }:
let
  ports = config.gradient.currentHost.ports;
in {

  virtualisation.oci-containers.containers.memory-repository = {
    # AAAAAAAAAAAAa!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    # IF YOU UPDATE THE BELOW
    # DON'T FORGET TO FIX THE INTERNAL ADAPTER SCRIPTS
    # FUCK YOU IF YOU FORGET FUCK YOU FUCK YOU FUCK YOU
    image = "ghcr.io/triliumnext/trilium:v0.99.3";
    pull = "newer";
    ports = [ "127.0.0.1:${toString ports.trilium}:8080" ];
    volumes = [ "/data/trilium:/home/node/trilium-data" ];
    environment = { TZ = config.time.timeZone; };
    extraOptions = [
      "--ip" "10.88.0.4"
    ];
  };

}