{ self, pkgs, ... }:

{

  imports = [
    self.inputs.nixos-hardware.nixosModules.common-gpu-amd
  ];

  hardware.amdgpu = {
    opencl.enable = true;
    initrd.enable = true;
  };

  environment.variables.AMD_VULKAN_ICD = "RADV";
  environment.variables.LIBVA_DRIVER_NAME = "radeonsi";
  environment.variables.VDPAU_DRIVER = "radeonsi";

  services.lact.enable = true;

  hardware.graphics.extraPackages = with pkgs; [
    lact
    libvdpau-va-gl
    rocmPackages.clr
    libva-vdpau-driver
    rocmPackages.rocm-runtime
    rocmPackages.rocm-device-libs
  ];

}