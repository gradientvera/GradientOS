{ pkgs, ... }:
{

  # As per https://github.com/aarron-lee/gpd-win-tricks/tree/main/win4-suspend-mods
  systemd.services.gpd-sleep-fix = {
    wantedBy = [ "sleep.target" ];
    before = [ "sleep.target" ];
    serviceConfig.User = "root";
    serviceConfig.Type = "oneshot";
    serviceConfig.RemainAfterExit = "yes";
    unitConfig.StopWhenUnneeded = "yes";
    path = [ pkgs.kmod ];
    script = ''
      modprobe -r bmi160_i2c
      modprobe -r bmi160_spi
      modprobe -r bmi160_core
    '';
    postStop = ''
      modprobe bmi160_core
      modprobe bmi160_spi
      modprobe bmi160_i2c
    '';
  };

}