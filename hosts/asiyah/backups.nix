{ config, ... }:
let
  secrets = config.sops.secrets;
in
{

  services.restic.backups.hokma = {
    paths = [
      "/home/vera"
      "/data/trilium"
      "/data/stardream"
      "/var/lib/mediarr"
      "/data/gradient-data"
      "/data/lfs"
      "/data/repositories"
    ];
  };

  services.restic.backups.pi = {
    initialize = true;
    repositoryFile = secrets.hokma-repository.path;
    passwordFile = secrets.hokma-password.path;
    environmentFile = secrets.hokma-environment.path;
    extraOptions = [
      "sftp.args='-4 -o StrictHostKeyChecking=accept-new -i ${config.sops.secrets.backups-ssh-priv.path}'"
    ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
    paths = [
      "/home/vera/.pi"
    ];
  };

}
