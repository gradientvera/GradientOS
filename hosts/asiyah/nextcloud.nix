{ config, pkgs, ... }:
{

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud31;
    hostName = "nextcloud.constellation.moe";
    database.createLocally = true;
    maxUploadSize = "4G";
    https = true;

    config = {
      dbtype = "pgsql";
      adminpassFile = config.sops.secrets.nextcloud-admin-password.path;
    };

    caching.redis = true; 
    configureRedis = true;

    appstoreEnable = false;
    extraAppsEnable = true;
    extraApps = {
        inherit (config.services.nextcloud.package.packages.apps)
        news
        contacts
        calendar
        tasks;
    };

  };

}