{ config, ... }:
{
  power.ups = {
    enable = true;

    ups."5E900UD" = {
      driver = "usbhid-ups";
      port = "auto";
      summary = ''
              vendorid = 0463
      '';
    };

    users.upsmon = {
      passwordFile = config.sops.secrets.upsmon-password.path;
      upsmon = "primary";
    };

    upsmon.monitor."5E900UD".user = "upsmon";
  };

}