{ config, pkgs, ... }:
let
  ports = config.gradient.currentHost.ports;
  name = "trilium-memory-repository";
  tag = "0.62.6"; # Corresponds to original image tag.
in {

  virtualisation.oci-containers.containers.memory-repository = {
    image = "${name}:${tag}";
    pull = "newer";
    imageFile = with pkgs.dockerTools;
      buildImage {
        inherit name tag;
        config.Cmd = [ "./start-memory-repository.sh" ];
        config.WorkingDir = "/usr/src/app";
        fromImage = pullImage {
          imageName = "zadam/trilium";
          imageDigest = "sha256:cfc1e54c0cdc733e904eb2e3e49a248bc4b4c8a4ae393a0155d69acaa88d920f";
          sha256 = "sha256-66tmPanpAZpddnm6tKDyl1dLBVHRU4m+Ghta+/7vNJw=";
        };
        runAsRoot = ''
          #!${pkgs.runtimeShell}
          cd /usr/src/app
          cp ${(pkgs.writeScript "start-memory-repository" ''
            #!/bin/sh
            ./start-docker.sh
          '')} ./start-memory-repository.sh
        '';
      };
    ports = [ "127.0.0.1:${toString ports.trilium}:8080" ];
    volumes = [ "/data/trilium:/home/node/trilium-data" ];
    environment = { TZ = config.time.timeZone; };
    extraOptions = [
      "--ip" "10.88.0.4"
    ];
  };

}