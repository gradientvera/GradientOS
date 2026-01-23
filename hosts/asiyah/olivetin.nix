{ config, pkgs, ports, ... }:
let
  systemdUnits = [
    "hytale-server.service"
  ];
  systemdUnitsFile = "/run/olivetin/systemd_units.json";
  systemdUnitsFileGenerate = "echo \"\" > ${systemdUnitsFile}\n" + builtins.concatStringsSep "\n" (builtins.map (u: ''
    echo "{\"unit\": \"${u}\", \"description\": \"$(systemctl show ${u} -P Description)\", \"status\": \"$(systemctl show ${u} -P SubState)\"}" >> ${systemdUnitsFile}
  '') systemdUnits);
in
{

  services.olivetin = {
    enable = true;
    path = [
      pkgs.jq
      pkgs.gnused
      pkgs.systemd
      pkgs.moreutils
      pkgs.coreutils
    ];
    settings = {
      ListenAddressSingleHTTPFrontend = "127.0.0.1:${toString ports.olivetin}";

      authHttpHeaderUsername = "X-Preferred-Username";
      authHttpHeaderUsergroup = "X-Groups";
      authHttpHeaderUsergroupSep = ",";

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

        # Systemd Unit Actions
        {
          title = "Start {{ systemd_unit.description }}";
          shell = "systemctl --no-block start {{ systemd_unit.unit }}";
          icon = ''<iconify-icon icon="ic:round-directions-run"></iconify-icon>'';
          entity = "systemd_unit";
          # enabledExpression = "{{ ne .CurrentEntity.status running }}";
          maxConcurrent = 1;
          triggers = [ "Update services file" ];
        }
        {
          title = "Restart {{ systemd_unit.description }}";
          shell = "systemctl --no-block restart {{ systemd_unit.unit }}";
          icon = ''<iconify-icon icon="material-symbols:restart-alt"></iconify-icon>'';
          entity = "systemd_unit";
          # enabledExpression = "{{ eq .CurrentEntity.status running }}";
          maxConcurrent = 1;
          triggers = [ "Update services file" ];
        }
        {
          title = "Stop {{ systemd_unit.description }}";
          shell = "systemctl --no-block stop {{ systemd_unit.unit }}";
          icon = ''<iconify-icon icon="zondicons:hand-stop"></iconify-icon>'';
          entity = "systemd_unit";
          # enabledExpression = "{{ eq .CurrentEntity.status running }}";
          maxConcurrent = 1;
          triggers = [ "Update services file" ];
        }
        {
          title = "Read {{ systemd_unit.description }} logs";
          shell = "journalctl --no-hostname --no-pager --since=\"1 day ago\" --output=short-iso --boot=0 -xu {{ systemd_unit.unit }}";
          icon = ''<iconify-icon icon="zondicons:book-reference"></iconify-icon>'';
          entity = "systemd_unit";
          popupOnStart = "execution-dialog";
          timeout = 60;
        }
        {
          title = "Update services file";
          shell = systemdUnitsFileGenerate;
          hidden = true;
          execOnStartup = true;
          execOnCron = [ "*/1 * * * *" ];
        }
      ];

      entities = [
        {
          file = systemdUnitsFile;
          name = "systemd_unit";
        }
      ];

      dashboards = [
        {
          title = "Main";
          contents = [
            {
              title = "Media";
              type = "fieldset";
              contents = [
                { title = "Restart Media Stack"; }
                { title = "Restart Auth Services"; }
              ];
            }
            # Generic Actions
            {
              title = "{{ systemd_unit.description }}";
              type = "fieldset";
              entity = "systemd_unit";
              contents = [
                {
                  title = "Status: {{ systemd_unit.status }}";
                  type = "display";
                }
                { title = "Start {{ systemd_unit.description }}"; }
                { title = "Restart {{ systemd_unit.description }}"; }
                { title = "Stop {{ systemd_unit.description }}"; }
                { title = "Read {{ systemd_unit.description }} logs"; }
              ];
            }
          ];
        }
      ];

    };
  };

  users.users.olivetin.extraGroups = [ "systemd-restart-units" "systemd-start-units" "systemd-stop-units" "systemd-journal" ];

}