{ pkgs, ... }:
{

  # As per https://github.com/aarron-lee/gpd-win-tricks/tree/main/win4-suspend-mods
  systemd.services.gpd-suspend-fix = {
    wantedBy = [ "suspend.target" ];
    before = [ "suspend.target" ];
    serviceConfig.User = "root";
    path = [ pkgs.kmod ];
    script = ''
      modprobe -r bmi260_i2c
      modprobe -r bmi260_core
    ''; 
  };

  systemd.services.gpd-resume-fix = {
    wantedBy = [ "suspend.target" ];
    after = [ "suspend.target" ];
    serviceConfig.User = "root";
    path = [ pkgs.kmod ];
    script = ''
      modprobe bmi260_i2c
      modprobe bmi260_core
    ''; 
  };

}