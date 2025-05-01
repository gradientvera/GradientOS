{ self, pkgs, ... }:

{

  imports = [
    self.inputs.nixos-hardware.nixosModules.common-gpu-amd
  ];

  environment.variables.AMD_VULKAN_ICD = "RADV";

  environment.systemPackages = [
    (pkgs.writeShellScriptBin "amdgpu-vr" ''
      echo "Setting AMD card to VR mode..."
      echo "4" > /sys/class/drm/card0/device/pp_power_profile_mode
      echo "Done!"
    '')
  ];

  systemd.packages = with pkgs; [
    lact
  ];

  hardware.graphics.extraPackages = with pkgs; [
    lact
    vaapiVdpau
    libvdpau-va-gl
    rocmPackages.clr
    rocmPackages.rocm-runtime
    rocmPackages.rocm-device-libs
  ];

}