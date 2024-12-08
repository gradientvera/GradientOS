{ ... }:
{

  services.restic.backups.hokma = {
    paths = [
      "/home/vera"
      "/data/trilium"
      "/data/stardream"
      "/var/lib/mediarr"
      "/data/gradient-data"
    ];
  };

}