{ config, ... }:
let
  ports = config.gradient.currentHost.ports;
in {

  virtualisation.oci-containers.containers.memory-repository = {
    # image = "triliumnext/trilium:latest"; # TODO: Port scripts
    image = "zadam/trilium:0.62.6";
    pull = "newer";
    ports = [ "127.0.0.1:${toString ports.trilium}:8080" ];
    volumes = [ "/data/trilium:/home/node/trilium-data" ];
    environment = { TZ = config.time.timeZone; };
    extraOptions = [
      "--ip" "10.88.0.4"
    ];
  };

}