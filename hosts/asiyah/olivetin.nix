{ config, pkgs, ports, ... }:
{

  services.olivetin = {
    enable = true;
    path = [
      pkgs.jq
      pkgs.systemd
      pkgs.coreutils
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
        {
          title = "Start Hytale Server";
          shell = "systemctl start hytale-server.service";
          icon = ''<iconify-icon icon="ic:round-directions-run"></iconify-icon>'';
        }
        {
          title = "Restart Hytale Server";
          shell = "systemctl restart hytale-server.service";
          icon = ''<iconify-icon icon="material-symbols:restart-alt"></iconify-icon>'';
        }
        {
          title = "Stop Hytale Server";
          shell = "systemctl stop hytale-server.service";
          icon = ''<iconify-icon icon="zondicons:hand-stop"></iconify-icon>'';
        }
      ];
    };
  };

  users.users.olivetin.extraGroups = [ "systemd-restart-units" "systemd-start-units" "systemd-stop-units" ];

}