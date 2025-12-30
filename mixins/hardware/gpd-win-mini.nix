{ pkgs, ... }:
{

  # As per https://github.com/aarron-lee/gpd-win-tricks/tree/main/win4-suspend-mods
  systemd.services.gpd-suspend-fix = {
    wantedBy = [ "suspend.target" ];
    before = [ "suspend.target" ];
    serviceConfig.User = "root";
    path = [ pkgs.kmod ];
    script = ''
      modprobe -r bmi160_i2c
      modprobe -r bmi160_spi
      modprobe -r bmi160_core
    ''; 
  };

  systemd.services.gpd-resume-fix = {
    wantedBy = [ "suspend.target" ];
    after = [ "suspend.target" ];
    serviceConfig.User = "root";
    path = [ pkgs.kmod ];
    script = ''
      modprobe bmi160_core
      modprobe bmi160_spi
      modprobe bmi160_i2c
    ''; 
  };

}