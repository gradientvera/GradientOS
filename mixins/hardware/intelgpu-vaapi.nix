{ pkgs, ... }:
{

  # Enable low-power encoding
  boot.extraModprobeConfig = ''
    options i915 enable_guc=2
  '';

  environment.systemPackages = with pkgs; [
    vdpauinfo
    libva-utils
    intel-gpu-tools
  ];

  hardware.intelgpu.enableHybridCodec = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      (intel-vaapi-driver.override { enableHybridCodec = true; })
      intel-compute-runtime
      intel-media-driver
      intel-media-sdk
      libvdpau-va-gl
      libva-vdpau-driver
    ];
    extraPackages32 = with pkgs.driversi686Linux; [
      (intel-vaapi-driver.override { enableHybridCodec = true; })
      intel-media-driver
      libvdpau-va-gl
      libva-vdpau-driver
    ];
  };

}