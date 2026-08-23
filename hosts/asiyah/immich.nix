{ config, ports, ... }:
let
  mediaLocation = "/data/immich";
  domain = "immich.constellation.moe";
in
{

  systemd.tmpfiles.settings."10-immich.conf".${mediaLocation}.d = {
    mode = "0750";
    user = config.services.immich.user;
    group = config.services.immich.group;
  };

  services.immich = {
    inherit mediaLocation;
    enable = true;
    host = "127.0.0.1";
    port = ports.immich;
    redis.enable = true;
    database.createDB = true;
    machine-learning.enable = true;
    accelerationDevices = null;
    # See https://docs.immich.app/install/config-file
    settings = {
      server.externalDomain = "https://${domain}";
      # See https://docs.immich.app/administration/oauth
      oauth = {
        enabled = "true";
        autoLaunch = "true";
        autoRegister = "true";
        buttonText = "Login with Gradient Identity";
        issuerUrl = "https://identity.gradient.moe/oauth2/openid/immich/.well-known/openid-configuration";
        clientId = "immich";
        clientSecret = ""; # PKCE moment
        scope = "openid email profile groups";
        defaultStorageQuota = null;
      };
      passwordLogin.enabled = "false";
      ffmpeg = {
        accel = "vaapi";
        acceptedVideoCodecs = [
          "h264"
          "hevc"
          "av1"
        ];
        targetResolution = "1080";
        targetVideoCodec = "av1";
        targetAudioCodec = "opus";
      };
    };
  };

  users.users.immich.extraGroups = [
    "video"
    "render"
  ];

  # Backup my media please.
  services.restic.backups.hokma.paths = [ mediaLocation ];

}
