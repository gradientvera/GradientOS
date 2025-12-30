{ self, pkgs, lib, ... }:

{

  imports = [
    self.inputs.nixos-hardware.nixosModules.common-gpu-amd
  ];

  hardware.amdgpu = {
    opencl.enable = true;
    initrd.enable = true;
  };

  gradient.kernel.transparent_hugepages.policy = lib.mkForce "madvise";

  boot.kernelParams = [
    # Prolly defaults to 1 already but just in case.
    "amdgpu.gpu_recovery=1"
    # Prevent some crashes
    "amdgpu.sg_display=0"
    "amdgpu.runpm=0"
  ];

  boot.extraModprobeConfig = ''
    options amdgpu si_support=1 cik_support=1
    options radeon si_support=0 cik_support=0
  '';

  environment.variables.AMD_VULKAN_ICD = "RADV";
  environment.variables.LIBVA_DRIVER_NAME = "radeonsi";
  environment.variables.VDPAU_DRIVER = "radeonsi";
  environment.variables.MESA_SHADER_CACHE_MAX_SIZE = "12G";

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