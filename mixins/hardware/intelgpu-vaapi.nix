{ pkgs, ... }:
{

  # Enable low-power encoding
  boot.extraModprobeConfig = ''
    options i915 enable_guc=2
  '';

  environment.systemPackages = with pkgs; [
    vdpauinfo
    libva-utils
  ];

  hardware.intelgpu.enableHybridCodec = true;
  hardware.intel-gpu-tools.enable = true;

  # Modern driver
  environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      # Accelerated Video Playback
      intel-media-driver

      # vdpau
      libva-vdpau-driver

      # QSV Support
      vpl-gpu-rt

      # OpenCL support
      intel-compute-runtime
      intel-ocl
    ];
    extraPackages32 = with pkgs.driversi686Linux; [
      # Accelerated Video Playback (32-bit support)
      (intel-vaapi-driver.override { enableHybridCodec = true; })
    ];
  };

}