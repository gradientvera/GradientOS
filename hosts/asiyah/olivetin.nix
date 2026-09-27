{
  config,
  pkgs,
  ports,
  ...
}:
let
  systemdUnits = [
    {
      name = "Palworld Server";
      unit = "palworld.service";
    }
    {
      name = "Hytale Server";
      unit = "hytale-server.service";
    }
    {
      name = "Project Zomboid Server";
      unit = "project-zomboid.service";
      stdin = "project-zomboid.stdin";
    }
    {
      name = "All The Mons (Lili) Server";
      unit = "all-the-mons-lili-server.service";
      stdin = "all-the-mons-lili-server.stdin";
    }
  ];
  systemdUnitsFile = "/run/olivetin/systemd_units.json";
  systemdUnitsFileGenerate =
    "echo \"\" > ${systemdUnitsFile}\n"
    + builtins.concatStringsSep "\n" (
      builtins.map (
        {
          unit,
          name ? null, # overrides the human-friendly title/description from the systemd service definition
          stdin ? null, # relative path to stdin socket from "/run/"
          ...
        }:
        let
          stdinPath = if stdin != null then "/run/${stdin}" else "";
          displayName = if name != null then name else "$(systemctl show ${unit} -P Description)";
        in
        ''
          echo "{\"unit\": \"${unit}\", \"title\": \"${displayName}\", \"description\": \"${displayName}\", \"status\": \"$(systemctl show ${unit} -P SubState)\", \"stdin\": \"${stdinPath}\"}" >> ${systemdUnitsFile}
        ''
      ) systemdUnits
    );
in
{

  services.olivetin = {
    enable = true;
    package = pkgs.olivetin-3k;
    path = [
      pkgs.jq
      pkgs.gnused
      pkgs.systemd
      pkgs.moreutils
      pkgs.coreutils
    ];
    settings = {
      ListenAddressSingleHTTPFrontend = "127.0.0.1:${toString ports.olivetin}";

      authHttpHeaderUsername = "X-Username";
      authHttpHeaderUserGroup = "X-Groups";
      authHttpHeaderUserGroupSep = ",";

      defaultPermissions = {
        view = true;
        exec = true;
        logs = false;
      };

      accessControlLists = [
        {
          name = "vera";
          matchUsernames = [ "vera" ];
          permissions = {
            view = true;
            exec = true;
            logs = true;
          };
          addToEveryAction = true;
        }
        {
          name = "neith";
          matchUsernames = [ "neith" ];
          permissions = {
            view = true;
            exec = true;
            logs = true;
          };
        }
        {
          name = "constellation";
          matchUsergroups = [ "constellation" ];
          matchUsernames = [
            "neith"
            "remie"
            "vera"
          ];
          permissions = {
            view = true;
            exec = true;
            logs = true;
          };
        }
      ];

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
          acls = [ "constellation" ];
          maxConcurrent = 1;
          timeout = 300; # 5 mins
        }
        {
          title = "Restart Discord Bot";
          shell = "systemctl restart podman-stardream.service";
          icon = ''<iconify-icon icon="bxs:bot" width="24" height="24"></iconify-icon>'';
          maxConcurrent = 1;
          timeout = 300; # 5 mins
        }
        {
          title = "Wake-On-Lan Bernkastel";
          shell = "${toString pkgs.wakeonlan}/bin/wakeonlan -i '192.168.1.255' '3c:78:95:5d:1a:ed'";
          acls = [ "vera" ];
          maxConcurrent = 1;
          timeout = 30;
        }
        {
          title = "Wake-On-Lan Hadal-Rainbow";
          shell = "${toString pkgs.wakeonlan}/bin/wakeonlan -i '192.168.1.255' '30:56:0f:07:05:ca'";
          acls = [ "neith" ];
          maxConcurrent = 1;
          timeout = 30;
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
          onclick = "execution-dialog";
          timeout = 60;
        }
        {
          title = "Send console command to {{ systemd_unit.description }}";
          exec = [
            "${pkgs.bash}/bin/bash"
            "-c"
            ''
              if [ ! -p "$2" ]; then
                echo "This service has no console stdin socket."
                exit 1
              fi
              if ! systemctl is-active --quiet "$3"; then
                echo "Service is not running."
                exit 1
              fi
              if printf "%s\\n" "$1" > "$2"; then
                echo "Sent: $1"
              else
                echo "Failed to write to console stdin."
                exit 1
              fi
            ''
            "olivetin-console-write"
            "{{ .Arguments.command }}"
            "{{ systemd_unit.stdin }}"
            "{{ systemd_unit.unit }}"
          ];
          icon = ''<iconify-icon icon="mdi:console"></iconify-icon>'';
          entity = "systemd_unit";
          arguments = [
            {
              name = "command";
              title = "Console command";
              type = "raw_string_multiline";
              description = "Sent to the server's stdin, e.g. say hi";
            }
          ];
          # hidden for units whose "stdin" field is empty in the entity JSON
          enabledExpression = ''{{ if ne .CurrentEntity.stdin "" }}true{{ else }}false{{ end }}'';
          maxConcurrent = 1;
          timeout = 30;
          triggers = [ "Update services file" ];
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
                { title = "Restart Discord Bot"; }
              ];
            }
            {
              title = "Infra";
              type = "fieldset";
              contents = [
                { title = "Wake-On-Lan Bernkastel"; }
                { title = "Wake-On-Lan Hadal-Rainbow"; }
              ];
            }
            # Generic Actions
            {
              title = "{{ .CurrentEntity.description }}";
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
                { title = "Send console command to {{ systemd_unit.description }}"; }
              ];
            }
          ];
        }
      ];

    };
  };

  users.users.olivetin.extraGroups = [
    "systemd-restart-units"
    "systemd-start-units"
    "systemd-stop-units"
    "systemd-journal"
  ];

}
