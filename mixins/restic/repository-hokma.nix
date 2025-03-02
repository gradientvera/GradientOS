/*
  Don't forget to add folders to back-up on your host-specific config after importing this!
*/
{ config, ... }:
let
  secrets = config.sops.secrets;
in
{

  services.restic.backups.hokma = {
    initialize = true;
    passwordFile = secrets.hokma-password.path;
    environmentFile = secrets.hokma-environment.path;
    repository = "azure:backup:/";
    
    timerConfig = {
      OnCalendar = "Mon *-*-* 10:00:00";
      # Prevent concurrent backups, as it can lead to duplicate files
      RandomizedDelaySec = "12h";
    };

    # Set these on your host!
    paths = [];

    # Sane defaults, but feel free to override
    exclude = [
      ".git"

      # tmpfs, no point in backing up
      "/home/*/tmp"

      # Too heavy and unimportant to back up
      "/home/*/Games"
      "/home/*/Downloads"
      "/home/*/.xlcore/ffxiv/game"
      "/home/*/Documents/Unity"

      # No point in backing these up
      "/home/*/.cache"
      "/home/*/.local/share/Trash"
      "/home/*/.local/share/containers"

      # Steam games
      "/home/*/.steam/"
      "/home/*/.local/share/Steam/steamapps/temp"
      "/home/*/.local/share/Steam/steamapps/*.acf"
      "/home/*/.local/share/Steam/steamapps/common"
      "/home/*/.local/share/Steam/steamapps/workshop"
      "/home/*/.local/share/Steam/steamapps/sourcemods"
      "/home/*/.local/share/Steam/steamapps/downloading"
      "/home/*/.local/share/Steam/steamapps/shadercache"
    ];
  };

  sops.secrets = 
  let
    secretCfg = { restartUnits = [ "restic-backups-hokma.service" ]; };
  in {
    hokma-password = secretCfg;
    hokma-environment = secretCfg;
  };

}