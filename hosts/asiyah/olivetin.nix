{ config, pkgs, ports, ... }:
{

  services.olivetin = {
    enable = true;
    path = [
      pkgs.systemd
    ];
    settings = {
      ListenAddressSingleHTTPFrontend = "127.0.0.1:${toString ports.olivetin}";
      actions = [
        {
          title = "Restart Media Stack";
          shell = "systemctl restart podman-create-mediarr-pod.service";
          # https://icon-sets.iconify.design/bx/tv/
          icon = ''<iconify-icon icon="bx:tv" width="24" height="24"></iconify-icon>'';
          maxConcurrent = 1;
          timeout = 600; # 10 mins
        }
        {
          title = "Restart Auth Services";
          shell = "systemctl restart kanidm.service oauth2-proxy.service";
          icon = ''<iconify-icon icon="bx:key" width="24" height="24"></iconify-icon>'';
          maxConcurrent = 1;
          timeout = 300; # 5 mins
        }
      ];
    };
  };

  users.users.olivetin.extraGroups = [ "systemd-restart-units" ];

}