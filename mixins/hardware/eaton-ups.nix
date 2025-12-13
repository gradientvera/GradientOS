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
      directives = [
        "override.battery.charge.low = 5"
        "override.battery.runtime.low = 60"
      ];
    };

    users.upsmon = {
      passwordFile = config.sops.secrets.upsmon-password.path;
      upsmon = "primary";
      actions = [ "set" "fsd" ];
      instcmds = [ "ALL" ];
    };

    upsmon.monitor."Eaton".user = "upsmon";
    
    upsd.listen = [
      {
        address = "0.0.0.0";
        port = 3493;
      }
    ];
  };

  environment.systemPackages = [
    pkgs.nut
  ];

  networking.firewall.interfaces.gradientnet.allowedTCPPorts = [
    3493
  ];

}