{ self, pkgs, ... }:

{

  imports = [
    self.inputs.nixos-hardware.nixosModules.common-gpu-amd
  ];

  environment.variables.AMD_VULKAN_ICD = "RADV";

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