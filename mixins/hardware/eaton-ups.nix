{ config, pkgs, ... }:
{
  power.ups = {
    enable = true;

    ups."Eaton" = {
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

    upsmon.monitor."Eaton".user = "upsmon";
  };

  environment.systemPackages = [
    pkgs.nut
  ];

}