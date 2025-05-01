/*
    Largely based on https://monado.freedesktop.org/valve-index-setup.html
*/
{ pkgs, ... }:
{

  environment.systemPackages = [
    pkgs.xrgears
  ];

  environment.sessionVariables = {
    PRESSURE_VESSEL_FILESYSTEMS_RW = "$XDG_RUNTIME_DIR/monado_comp_ipc";
  };

  services.monado = {
    enable = true;
    highPriority = true;
    defaultRuntime = true;
  };

}