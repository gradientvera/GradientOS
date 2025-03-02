/*
    Largely based on https://monado.freedesktop.org/valve-index-setup.html
*/
{ pkgs, ... }:
{

  environment.systemPackages = [
    pkgs.xrgears

    (pkgs.writeShellScriptBin "amdgpu-vr" ''
      echo "Setting AMD card to VR mode..."
      echo "4" > /sys/class/drm/card0/device/pp_power_profile_mode
      echo "Done!"
    '')
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