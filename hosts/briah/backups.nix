{ config, ... }:
{

  services.restic.backups.hokma = {
    paths = [
      "/home/vera"
      config.services.home-assistant.configDir
      config.services.zigbee2mqtt.dataDir
    ];
  };

}